--Business Questions to Address

--3.1 Revenue Overview
/*
What is the total revenue of the company?
How is revenue distributed across product categories?
Which category contributes the largest share of revenue?
*/

--1:
SELECT SUM(total_sales) AS total_sales_revenue
FROM sales_analysis;

--2:
SELECT
	category,
	SUM(total_sales) AS total_sales_revenue
FROM sales_analysis
GROUP BY category;

--3:
SELECT
	category,
	SUM(total_sales) AS total_sales_revenue
FROM sales_analysis
GROUP BY category
ORDER BY total_sales_revenue DESC
LIMIT 1;

/* 3.2 Typical Transaction Value
Management wants to understand a “typical” transaction.

Calculate the average transaction value
Calculate the median transaction value
Based on the data, explain which metric is more appropriate and why, in case of NULLs
*/

--1:
SELECT
	AVG(COALESCE(total_sales, 0)) AS total_sales_avg
FROM sales_analysis;

--2:
SELECT
	percentile_cont(0.5) WITHIN GROUP (ORDER BY COALESCE(total_sales, 0)) AS total_sales_median
FROM sales_analysis;

--3: 
/* 
"Although the mean (251.67) and median (251.14) are close in the current sample, the median is a more relevant and reliable indicator.
Reasons:
If asymmetry (abnormally high receipts) occurs, the arithmetic mean (AVG) will be significantly skewed upward. The median is robust to such outliers.
If NULL values are present, the AVG function completely ignores them in its calculations, artificially changing the calculation base (denominator). The median, as a positional metric, is much less sensitive to missing data and more accurately reflects a typical transaction."
*/


--3.3 NULL Impact Assessment
/*
Discounts are inconsistently recorded.

1.0 How many transactions have NULL discounts?
2.1Calculate average discount using:
default behavior
zero imputation
average imputation
median imputation
Explain how each approach changes interpretation
*/

--1:
SELECT
	COUNT(*)
FROM sales_analysis
WHERE discount IS NULL;

--2.1: 
SELECT AVG(discount) AS def_avg_discount
FROM sales_analysis;

--2.2:
SELECT 
	AVG(COALESCE(discount, 0)) AS avg_discount_zero
FROM sales_analysis;

--2.3:
SELECT
	AVG(COALESCE(discount, (SELECT AVG(discount) FROM sales_analysis))) AS avg_avg_discount
FROM sales_analysis;

--2.4:
SELECT
	percentile_cont(0.5) WITHIN GROUP (
		ORDER BY COALESCE(
			discount,
			(SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY discount) FROM sales_analysis)
		)
	) AS total_sales_median
FROM sales_analysis;

--3:
/*
Default behavior
SQL automatically discards all empty rows (NULL) and calculates the average only for receipts that included a discount.
Business interpretation: This metric answers the question: "What is the average discount size in cases where we decide to offer one?"

Zero imputation
We force the database to say, "Empty means there was no discount, meaning it's zero." The denominator (the number of transactions) grows to the actual size of the database.

Average imputation and median imputation
How it affects data: You take the average (or median) discount value and insert it into all blank receipts.
Business interpretation: This is called data falsification. Using this method, you mathematically create an alternative reality in which every first-time customer in the store received a discount.
*/

/*
3.4 Revenue Distribution Analysis
To improve pricing strategy, management wants to understand revenue ranges.

Group transactions into 50-unit revenue ranges
For each range, compute:
number of transactions
total revenue
Identify the dominant revenue range
*/

--1:
SELECT
	FLOOR(total_sales / 50) * 50 AS bin_sales
FROM sales_analysis
GROUP BY bin_sales
ORDER BY bin_sales DESC;

--2:
SELECT
	FLOOR(total_sales / 50) * 50 AS bin_sales,
	COUNT(transaction_id) AS count_transaction,
	SUM(total_sales) AS total_revenue
FROM sales_analysis
GROUP BY bin_sales
ORDER BY bin_sales DESC;

--3:
SELECT
	FLOOR(total_sales / 50) * 50 AS bin_sales,
	COUNT(transaction_id) AS count_transaction,
	SUM(total_sales) AS total_revenue
FROM sales_analysis
GROUP BY bin_sales
ORDER BY count_transaction DESC LIMIT 1;

--3.5 
/*
. Data Quality Check
Before finalizing KPIs:

Check for duplicate transaction IDs
Explain the risk of aggregating employee salary directly from this table
Identify one additional potential data quality risk in sales_analysis
*/

--1:
SELECT
	transaction_id,
	COUNT(*) AS duplicate_count
FROM sales_analysis
GROUP BY transaction_id
HAVING COUNT(*) > 1;

--2:
/*
Employee salary is a static attribute. Storing it in a transactional table duplicates the salary value for every single sale made by the employee. Aggregating this column (e.g., using SUM) will exponentially inflate total salary metrics and produce completely false financial reports.
*/

--3:
/*
The presence of NULL or logically impossible values (like negative transaction amounts or negative quantities) in critical revenue columns. This will severely distort financial aggregations and final KPIs.
*/

