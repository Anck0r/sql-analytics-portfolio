/*
Scenario
You are asked to produce reliable KPIs from transactions_text_demo.

Business questions:

revenue by category
number of unique customers
average transaction value

4.1 | Profiling
Write SQL queries to assess:

1: phone number format diversity
2: category fragmentation
3: impact of dirty text on GROUP BY

Use only diagnostic functions.
*/

--1:
SELECT DISTINCT
	raw_phone
FROM transactions_text_demo;

--2:
SELECT
	category_raw,
	COUNT(*) AS count
FROM transactions_text_demo
GROUP BY category_raw
ORDER BY category_raw;

--3:
SELECT
	category_raw,
	SUM(quantity) AS total_revenue
FROM transactions_text_demo
GROUP BY category_raw;

/*
4.2 | Standardization Layer
Create a cleaned SELECT projection (no updates) that includes:

1: standardized phone number (last 8 digits)
2: cleaned category (no annotations, trimmed)
3: revenue per transaction

Use:

REGEXP_REPLACE()
TRIM()
SUBSTRING()
CONCAT() where relevant
*/

SELECT 
    RIGHT(REGEXP_REPLACE(raw_phone, '[^0-9]', '', 'g'), 8) AS clean_phone,
    TRIM(SUBSTRING(category_raw, 1, 11)) AS clean_category,
    price AS transaction_revenue
FROM transactions_text_demo;

--4.3
/*
KPI Comparison
Compute and compare:

1: revenue by raw category
2: revenue by cleaned category
3: unique customers (raw vs cleaned phone)

Use GROUP BY in all comparisons.
*/

--1:
SELECT
	category_raw,
	SUM(price)
FROM transactions_text_demo
GROUP BY category_raw;

--2:
SELECT 
	SUBSTRING(category_raw, 1, 11) AS clean_category,
	SUM(price)
FROM transactions_text_demo
GROUP BY SUBSTRING(category_raw, 1, 11);

--3:
SELECT
	SUBSTRING(category_raw, 1, 11) AS clean_category,
	SUM(price) AS total_revenue,
	COUNT(DISTINCT raw_phone) AS raw_unique_clients,
	COUNT(DISTINCT RIGHT(REGEXP_REPLACE(raw_phone, '[^0-9]', '', 'g'), 8)) AS real_unique_clients
FROM transactions_text_demo
GROUP BY SUBSTRING(category_raw, 1, 11)
FROM transactions_text_demo
GROUP BY RIGHT(REGEXP_REPLACE(raw_phone, '[^0-9]', '', 'g'), 8), raw_phone;

/*
4.4 | Analytical Explanation
Briefly explain:

1: why KPIs changed
2: which cleaning step had the biggest impact
3: what assumptions you made
4: what could silently break in production

1. The data results changed because we cleaned the data and reorganized it in a more efficient way.
2. I believe cleansing is equally important regardless of its type, but if that's not the case, then I'm considering REGEXP_REPLACE.
3. I believe data cleansing is a very subtle and important step in data analysis, but it needs to be handled with care, as any tiny gap can change the entire analysis process.
4. Lack of input validation: The website or app allows the user to enter the phone number in any format (with pluses, parentheses, letters), instead of restricting input to numbers only.
*/