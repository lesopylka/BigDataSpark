SELECT 'top_revenue' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT supplier_name AS entity, '' AS period, SUM(sale_total_price) AS value FROM sales  GROUP BY supplier_name ORDER BY value DESC, entity LIMIT 5) result
UNION ALL
SELECT 'average_price' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT supplier_name AS entity, '' AS period, AVG(CAST(product_price AS DOUBLE)) AS value FROM sales  GROUP BY supplier_name) result
UNION ALL
SELECT 'country_revenue' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT supplier_country AS entity, '' AS period, SUM(sale_total_price) AS value FROM sales  GROUP BY supplier_country) result;
