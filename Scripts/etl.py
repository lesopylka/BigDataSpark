import json
from pathlib import Path

import requests
from pyspark.sql import SparkSession, functions as F


JDBC_URL = "jdbc:postgresql://postgres:5432/postgres"
JDBC_OPTIONS = {"user": "postgres", "password": "postgres", "driver": "org.postgresql.Driver"}


def read_table(spark, name):
    return spark.read.jdbc(JDBC_URL, name, properties=JDBC_OPTIONS)


def write_table(frame, name):
    # Сохраняем DDL и внешние ключи. Очистка выполняется до Spark-записи.
    frame.write.jdbc(JDBC_URL, name, mode="append", properties=JDBC_OPTIONS)


def read_products(spark):
    products = read_table(spark, "star.dim_product")
    products = products.join(read_table(spark, "star.dim_product_category"), "category_key")
    products = products.join(read_table(spark, "star.dim_brand"), "brand_key")
    return products.withColumnRenamed("category_name", "product_category").withColumnRenamed("brand_name", "product_brand")


def clickhouse(query, data=None):
    response = requests.post(
        "http://clickhouse:8123/", params={"query": query}, auth=("lab", "lab"),
        data=data, timeout=120,
    )
    response.raise_for_status()


def main():
    spark = SparkSession.builder.appName("sales_etl").getOrCreate()
    spark.conf.set("spark.sql.session.timeZone", "UTC")
    groups = json.loads(Path("model.json").read_text())
    source = read_table(spark, "public.mock_data").cache()
    if source.count() != 10000 or source.select("sale_key").distinct().count() != 10000:
        raise ValueError("Неверное количество исходных продаж")

    data = source
    for name, columns in groups.items():
        # Измерение содержит версию атрибутов, а не случайный числовой ID из CSV.
        data = data.withColumn(f"{name}_key", F.sha2(F.to_json(F.struct(*columns)), 256))
    data = data.withColumn("date_key", F.date_format(F.to_date("sale_date", "M/d/yyyy"), "yyyy-MM-dd"))
    if data.filter(F.col("date_key").isNull()).limit(1).count():
        raise ValueError("Не удалось разобрать дату продажи")
    data = data.withColumn("category_key", F.sha2(F.col("product_category"), 256))
    data = data.withColumn("brand_key", F.sha2(F.col("product_brand"), 256))
    data = data.cache()

    import psycopg
    with psycopg.connect("host=postgres dbname=postgres user=postgres password=postgres") as conn:
        conn.execute("TRUNCATE star.fact_sales, star.dim_customer, star.dim_seller, star.dim_product, star.dim_store, star.dim_supplier, star.dim_date, star.dim_product_category, star.dim_brand")

    # Категория и бренд хранятся отдельно, как в первой лабораторной.
    write_table(data.select("category_key", F.col("product_category").alias("category_name")).distinct(), "star.dim_product_category")
    write_table(data.select("brand_key", F.col("product_brand").alias("brand_name")).distinct(), "star.dim_brand")
    for name, columns in groups.items():
        if name == "product":
            columns = [column for column in columns if column not in {"product_category", "product_brand"}]
            write_table(data.select("product_key", *columns, "category_key", "brand_key").distinct(), "star.dim_product")
        else:
            write_table(data.select(f"{name}_key", *columns).distinct(), f"star.dim_{name}")
    dates = data.select("date_key").distinct().withColumn("full_date", F.to_date("date_key"))
    dates = dates.withColumn("year_key", F.substring("date_key", 1, 4)).withColumn("month_key", F.substring("date_key", 1, 7))
    write_table(dates, "star.dim_date")
    facts = data.select(
        "sale_key", "source_file", F.col("id").cast("int").alias("source_id"),
        *[f"{name}_key" for name in groups], "date_key",
        F.col("sale_quantity").cast("int").alias("sale_quantity"),
        F.col("sale_total_price").cast("decimal(18,2)").alias("sale_total_price"),
    )
    write_table(facts, "star.fact_sales")

    # Витрины читают сохраненную снежинку, а не исходный DataFrame.
    sales = read_table(spark, "star.fact_sales")
    for name in groups:
        if name != "seller":
            dimension = read_products(spark) if name == "product" else read_table(spark, f"star.dim_{name}")
            sales = sales.join(dimension, f"{name}_key")
    sales = sales.join(read_table(spark, "star.dim_date"), "date_key")
    sales.createOrReplaceTempView("sales")
    read_products(spark).createOrReplaceTempView("products")
    clickhouse("CREATE DATABASE IF NOT EXISTS lab")
    for path in sorted(Path("sql/reports").glob("*.sql")):
        table = f"lab.report_{path.stem}"
        result = spark.sql(path.read_text().rstrip().rstrip(";"))
        clickhouse(f"CREATE TABLE IF NOT EXISTS {table} (metric String, entity String, period String, value Nullable(Float64)) ENGINE=MergeTree ORDER BY (metric, entity, period)")
        clickhouse(f"TRUNCATE TABLE {table}")
        payload = "\n".join(result.toJSON().collect()).encode("utf-8")
        clickhouse(f"INSERT INTO {table} FORMAT JSONEachRow", payload)
        print(f"Сохранена витрина {table}")
    spark.stop()


if __name__ == "__main__":
    main()
