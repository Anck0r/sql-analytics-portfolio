/*
5.1
Story-driven task:

You are asked to evaluate sales performance over time for management.

Required steps:

build monthly, quarterly, and yearly aggregations
compare trends across different grains
identify:
strongest growth period
weakest period
compute:
days since last transaction per customer
use AGE() to describe customer recency in calendar terms
Visualization:

use pgAdmin charts to visualize:
monthly revenue trend
quarterly comparison
annotate findings with written interpretation
*/

--STEP 1
SELECT
	DATE_TRUNC('month', order_date_date) AS month,
	SUM(total_sales) AS total_revenue
FROM sales_analysis
GROUP BY DATE_TRUNC('month', order_date_date)
ORDER BY month;

--STEP 2
SELECT
	DATE_TRUNC('quarter', order_date_date) AS quarter,
	SUM(total_sales) AS total_revenue
FROM sales_analysis
GROUP BY DATE_TRUNC('quarter', order_date_date)
ORDER BY quarter

--STEP 3
SELECT
	DATE_TRUNC('year', order_date_date) AS year,
	SUM(total_sales),
FROM sales_analysis
GROUP BY DATE_TRUNC('year', order_date_date)
ORDER BY year;

--STEP 4
SELECT
    customer_name,
    MAX(order_date_date) AS last_purchase_date,
    CURRENT_DATE - MAX(order_date_date) AS days_since_last_txn,
    AGE(CURRENT_DATE, MAX(order_date_date)) AS calendar_recency
FROM sales_analysis
GROUP BY customer_name
ORDER BY days_since_last_txn;