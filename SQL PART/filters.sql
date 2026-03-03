--2.1 Complex Transaction Segmentation (CASE + WHERE)

SELECT 
	total_sales,
	discount,
	category,
	city,
	transaction_id,
	CASE
		WHEN discount < 0.3 AND total_sales > 100 THEN 'Maximum demand'
		WHEN discount > 0.3 AND total_sales < 70 THEN 'Minimum demand'
		ELSE 'Standard demand'
	END AS product_demand
FROM sales_analysis
WHERE category = 'Electronics' AND YEAR = 2023 LIMIT 100

/*
Using this query, I (in a specific sample) divided the products into 3 categories - Maximum, Standard and Minimum demands.
*/

--2.2 Category-Level Performance Analysis (CASE + GROUP BY + HAVING)

SELECT
	category,
	SUM(total_sales) AS total_sales_amount,
	COUNT(transaction_id) AS transaction_count,
	AVG(discount) AS discount_avg,
	CASE
		WHEN SUM(total_sales) > 10000 AND COUNT(transaction_id) < 100 THEN 'Premium-Segment-Product'
		WHEN SUM(total_sales) < 1000 AND COUNT(transaction_id) > 10000 THEN 'Economy-Class-Product'
		ELSE 'Standard Class Product'
	END AS product_class
FROM sales_analysis
WHERE year = 2023
GROUP BY category
HAVING COUNT(transaction_id) > 50
ORDER BY discount_avg DESC;

/* 
Using this query, I (in a specific sample) divided the products into 3 categories: Premium, Economy and Standard.
*/

--2.3 City-Level Activity Analysis (COUNT + HAVING + CASE)

SELECT
	city,
	COUNT(*),
	CASE
		WHEN COUNT(*) > 6 THEN 'High Activity'
		WHEN COUNT(*) < 4 THEN 'Low Activity'
		ELSE 'Standard Activity'
	END AS city_activity
FROM sales_analysis
WHERE year = 2023
GROUP BY city
HAVING COUNT(*) > 1
ORDER BY city_activity DESC;

/*
Using this query, I (in a specific sample) divided the areas into 3 categories - High Activity, Low Activity, Standard Activity (determining the activity in these areas).
*/

--2.4 Discount Behavior Analysis (CASE + HAVING)

SELECT
	category,
	AVG(discount) AS discount_avg,
	SUM(total_sales) AS total_sales_amount,
	CASE
		WHEN AVG(discount) > 0.3 THEN 'Big discount'
		WHEN AVG(discount) < 0.1 THEN 'Small discount'
		ELSE 'Standard discount'
	END AS discount_class
FROM sales_analysis
WHERE year = 2023
GROUP BY category
HAVING SUM(total_sales) > 300
ORDER BY category DESC

/*
Using this query, I (in a specific sample) divided discounts into 3 categories - Big Discount, Small Discount and Standard Discount.
*/