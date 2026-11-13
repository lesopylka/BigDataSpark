SELECT COUNT(*) AS sales_count, COUNT(DISTINCT sale_key) AS unique_sales,
       SUM(sale_quantity) AS total_quantity, SUM(sale_total_price) AS total_amount
FROM star.fact_sales;
-- После завершения потока ожидается 10000 продаж.
SELECT COUNT(*) AS broken_links
FROM star.fact_sales f
LEFT JOIN star.dim_customer c USING (customer_key)
LEFT JOIN star.dim_product p USING (product_key)
LEFT JOIN star.dim_store s USING (store_key)
LEFT JOIN star.dim_supplier sp USING (supplier_key)
LEFT JOIN star.dim_seller se USING (seller_key)
LEFT JOIN star.dim_date d USING (date_key)
WHERE c.customer_key IS NULL OR p.product_key IS NULL OR s.store_key IS NULL
   OR sp.supplier_key IS NULL OR se.seller_key IS NULL OR d.date_key IS NULL;

-- Товар должен ссылаться на существующие категорию и бренд.
SELECT COUNT(*) AS broken_product_links
FROM star.dim_product p
LEFT JOIN star.dim_product_category c USING (category_key)
LEFT JOIN star.dim_brand b USING (brand_key)
WHERE c.category_key IS NULL OR b.brand_key IS NULL;
