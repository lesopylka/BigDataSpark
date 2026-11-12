SELECT 'top_revenue' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT customer_email AS entity, '' AS period, SUM(sale_total_price) AS value FROM sales  GROUP BY customer_email ORDER BY value DESC, entity LIMIT 10) result
UNION ALL
SELECT 'country_customers' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT customer_country AS entity, '' AS period, COUNT(DISTINCT customer_email) AS value FROM sales  GROUP BY customer_country) result
UNION ALL
SELECT 'average_order' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT customer_email AS entity, '' AS period, AVG(sale_total_price) AS value FROM sales  GROUP BY customer_email) result;
