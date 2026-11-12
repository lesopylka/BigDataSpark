SELECT 'highest_rating' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT product_name entity, '' period, AVG(CAST(product_rating AS DOUBLE)) value FROM products GROUP BY product_name ORDER BY value DESC, entity LIMIT 10) result
UNION ALL
SELECT 'lowest_rating' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT product_name entity, '' period, AVG(CAST(product_rating AS DOUBLE)) value FROM products GROUP BY product_name ORDER BY value ASC, entity LIMIT 10) result
UNION ALL
SELECT 'most_reviews' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT product_name entity, '' period, SUM(CAST(product_reviews AS BIGINT)) value FROM products GROUP BY product_name ORDER BY value DESC, entity LIMIT 10) result
UNION ALL
SELECT 'rating_quantity_correlation' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT 'all' entity, '' period, CORR(rating, quantity) value FROM (SELECT p.product_name, AVG(CAST(p.product_rating AS DOUBLE)) rating, q.quantity FROM products p JOIN (SELECT product_name, SUM(sale_quantity) quantity FROM sales GROUP BY product_name) q ON p.product_name = q.product_name GROUP BY p.product_name, q.quantity) grouped) result;
