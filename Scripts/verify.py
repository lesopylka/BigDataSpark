import json
import time
from decimal import Decimal
from pathlib import Path
import psycopg
import requests


def main():
    expected = json.loads(Path("expected.json").read_text())
    with psycopg.connect("host=postgres dbname=postgres user=postgres password=postgres") as conn:
        for attempt in range(180):
            row = conn.execute("SELECT COUNT(*), COUNT(DISTINCT sale_key), SUM(sale_quantity), SUM(sale_total_price) FROM star.fact_sales").fetchone()
            if row[0] == expected["sales_count"]:
                break
            time.sleep(2)
        assert row == (expected["sales_count"], expected["unique_sales"], expected["total_quantity"], Decimal(expected["total_amount"])), row
        for name in ["customer", "seller", "product", "store", "supplier", "date"]:
            count = conn.execute(f"SELECT COUNT(*) FROM star.fact_sales f LEFT JOIN star.dim_{name} d USING ({name}_key) WHERE d.{name}_key IS NULL").fetchone()[0]
            assert count == 0, (name, count)
        broken = conn.execute("SELECT COUNT(*) FROM star.dim_product p LEFT JOIN star.dim_product_category c USING (category_key) LEFT JOIN star.dim_brand b USING (brand_key) WHERE c.category_key IS NULL OR b.brand_key IS NULL").fetchone()[0]
        assert broken == 0, broken
        for name in ["products", "customers", "time", "stores", "suppliers", "quality"]:
            response = requests.post("http://clickhouse:8123/", auth=("lab", "lab"), data=f"SELECT count() FROM lab.report_{name}", timeout=30)
            response.raise_for_status()
            assert int(response.text) > 0
        response = requests.post("http://clickhouse:8123/", auth=("lab", "lab"), data="SELECT sum(value) FROM lab.report_products WHERE metric = 'category_revenue'", timeout=30)
        response.raise_for_status()
        assert abs(Decimal(response.text.strip()) - Decimal(expected["total_amount"])) < Decimal("0.01")
    print("Количество продаж, ключи, количество товара и сумма совпадают с исходными данными")


if __name__ == "__main__":
    main()
