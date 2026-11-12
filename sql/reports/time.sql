SELECT 'month_revenue' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT 'all' AS entity, month_key AS period, SUM(sale_total_price) AS value FROM sales  GROUP BY 'all', month_key) result
UNION ALL
SELECT 'year_revenue' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT 'all' AS entity, year_key AS period, SUM(sale_total_price) AS value FROM sales  GROUP BY 'all', year_key) result
UNION ALL
SELECT 'month_average_order' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT 'all' AS entity, month_key AS period, AVG(sale_total_price) AS value FROM sales  GROUP BY 'all', month_key) result
UNION ALL
SELECT 'month_revenue_change' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT 'all' entity, month_key period, revenue - LAG(revenue) OVER (ORDER BY month_key) value FROM (SELECT month_key, SUM(sale_total_price) revenue FROM sales GROUP BY month_key) months) result
UNION ALL
SELECT 'year_revenue_change' AS metric, entity, period, CAST(value AS DOUBLE) AS value FROM (SELECT 'all' entity, year_key period, revenue - LAG(revenue) OVER (ORDER BY year_key) value FROM (SELECT year_key, SUM(sale_total_price) revenue FROM sales GROUP BY year_key) years) result;
