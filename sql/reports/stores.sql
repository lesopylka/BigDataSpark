SELECT 'top_revenue' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT store_email AS entity, '' AS period, SUM(sale_total_price) AS value FROM sales  GROUP BY store_email ORDER BY value DESC, entity LIMIT 5) result
UNION ALL
SELECT 'city_revenue' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT CONCAT(store_country, ' / ', store_city) AS entity, '' AS period, SUM(sale_total_price) AS value FROM sales  GROUP BY CONCAT(store_country, ' / ', store_city)) result
UNION ALL
SELECT 'country_revenue' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT store_country AS entity, '' AS period, SUM(sale_total_price) AS value FROM sales  GROUP BY store_country) result
UNION ALL
SELECT 'average_order' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT store_email AS entity, '' AS period, AVG(sale_total_price) AS value FROM sales  GROUP BY store_email) result;
