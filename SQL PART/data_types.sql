--Enforce Missing Business Rules with ALTER TABLE

--1.1 Business rules:

--1: Employees emails must be unique
--2: Emoployee phone numbers must be mandatory
--3: Product prices must be non-negative
--4: Sales totals must be non-negative

ALTER TABLE employees
ADD CONSTRAINT uq_employees_email UNIQUE (email);

ALTER TABLE employees
ALTER COLUMN phone_number SET NOT NULL;

ALTER TABLE products
ADD CONSTRAINT chk_products_price CHECK (price >= 0);

ALTER TABLE sales
ADD CONSTRAINT chk_sales_total CHECK (total_sales >= 0);

--1.2 Add a New Analytical Attribute

--Add a new column to the sales table:

ALTER TABLE sales
ADD COLUMN sales_channel TEXT;

--Add a constraint to enforce valid values.

ALTER TABLE sales
ADD CONSTRAINT chk_sales_channel
CHECK (sales_channel IN ('online', 'store'));

--Populate the column with sample values.

UPDATE sales
SET sales_channel = 'online'
WHERE transaction_id % 2 = 0;

/* 
   Adding a column named (sales_channel) in text format to a table named (sales).
   Restrict the 'sales_channel' column to only accept 'online' or 'store'.
   The query updates the sales table by setting the 'sales_channel' column to 'online' for all records where the 'transaction_id' is an even number.
*/


--1.3 Add Indexes for Query Performance

CREATE INDEX idx_sales_product_id
ON sales (product_id);

CREATE INDEX idx_sales_customer_id
ON sales (customer_id);

CREATE INDEX idx_products_category
ON products (category);

--1.4 Validate Index Usage with EXPLAIN

EXPLAIN
SELECT
	product_id,
	SUM(total_sales) AS total_revenue
FROM sales
GROUP BY product_id;

/*
Brief Interpretation:

1. Is a sequential scan used?
   Yes, a sequential scan (Seq Scan) is used.

2. Does PostgreSQL use an index?
   No, an index is not used here.

3. Why might the planner choose this plan?
   Since there is no WHERE clause filtering the data, the database must read all rows to group them and calculate the sum. When reading an entire table, a sequential scal is more efficient than an index scan.
*/

--1.5 Reduce Query Cost by Refining SELECT

--Original query:
SELECT *
FROM sales;

--Refined query:
SELECT
	transaction_id,
	product_id,
	total_sales
FROM sales;

/*
Explanation:

1. Why this reduces costs:
Replacing SELECT * with specific columns reduces the overall payload. It saves disk I/O, memory, and network bandwidth because the database engine only retrieves and transfers the necessary columns.

2. When SELECT * might be acceptable:
It is acceptable for ad-hoc queries, initial data exploration to understand the table structure, or debugging.
*/


--1.6 ORDER BY and LIMIT for Business Questions

/*
Write a query that:

1: aggregates sales
2: sorts by revenue
3: limits the output
*/

EXPLAIN
SELECT
	product_id,
	SUM(total_sales) AS total_revenue
FROM sales
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 5;

/*

1. Cost of sorting: 
   The total cost of the Sort operation is approximately 144.16. 

2. Do indexes help in this case? 
   No, they do not. The execution plan explicitly shows a Sequential Scan (Seq Scan). Indexes cannot be used here because the query reads the entire table (no WHERE clause) and the sorting is performed on a dynamically aggregated column (SUM of total_sales), which cannot be indexed in advance.
*/



--1.7 DISTINCT vs GROUP BY (Efficiency Comparison)

--DISTINCT
EXPLAIN
SELECT DISTINCT
	category,
	price
FROM products;

--GROUP BY
EXPLAIN
SELECT
	category,
	price
FROM products
GROUP BY category, price;

/*
1. Are the query execution plans similar?
   Yes, they are completely identical. 

2. Which one has a lower estimated cost?
   Neither. The estimated total costs are exactly the same.

3. Why might PostgreSQL optimize them the same way?
   Because DISTINCT and GROUP BY (when used without aggregate functions) are logically equivalent. The PostgreSQL query planner recognizes that both queries have the exact same goal—returning unique combinations of rows—and therefore translates them into the same execution plan under the hood (typically using HashAggregate).
*/

--1.8 Constraint Enforcement Test

INSERT INTO employees (email, first_name)
VALUES ('lori66@example.org', 'Lori');
/*
ERROR:  duplicate key value violates unique constraint "employees_pkey"
Key (employee_id)=(3) already exists. 

SQL state: 23505
Detail: Key (employee_id)=(3) already exists.
*/

UPDATE products
SET price = -5
WHERE product_id = 1;

/*
ERROR:  new row for relation "products" violates check constraint "chk_products_price"
Failing row contains (1, Increase, -5, Authority audience always force reality mission long., Electronics). 

SQL state: 23514
Detail: Failing row contains (1, Increase, -5, Authority audience always force reality mission long., Electronics).
*/

--1.9 Reflection (Short Answer)
/*
Reflection:

1. Which constraints provide the highest business value?
   UNIQUE and NOT NULL constraints are critical for identifying core entities reliably (e.g., ensuring no duplicate customer emails). Meanwhile, CHECK constraints prevent logically impossible inputs (like negative prices) that would otherwise corrupt business analytics and reporting.

2. Which index would you prioritize in a production environment?
   In a production environment, I would prioritize indexing foreign keys that are frequently used in JOIN operations, as well as columns that are heavily used in WHERE clauses for filtering large datasets.

3. What are the signs that a query needs optimization?
   Primary indicators include excessively high costs or long execution times in the EXPLAIN output, the presence of Sequential Scans (Seq Scan) on massive tables when only a small subset of rows is actually needed, and expensive memory-intensive Sort operations.
*/