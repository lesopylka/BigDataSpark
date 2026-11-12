SELECT 'top_quantity' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT product_name AS entity, '' AS period, SUM(sale_quantity) AS value FROM sales  GROUP BY product_name ORDER BY value DESC, entity LIMIT 10) result
UNION ALL
SELECT 'category_revenue' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT product_category AS entity, '' AS period, SUM(sale_total_price) AS value FROM sales  GROUP BY product_category) result
UNION ALL
SELECT 'average_rating' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT product_name entity, '' period, AVG(CAST(product_rating AS DOUBLE)) value FROM products GROUP BY product_name) result
UNION ALL
SELECT 'reviews' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT product_name entity, '' period, SUM(CAST(product_reviews AS BIGINT)) value FROM products GROUP BY product_name) result;
