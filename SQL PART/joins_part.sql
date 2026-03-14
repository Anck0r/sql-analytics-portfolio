--Q1: Who are our customers and where are they located?
--Note: Due to the schema design, we only know a customer's location based on where their orders were shipped. We use DISTINCT to avoid listing the same customer multiple times for the same city.


SELECT DISTINCT 
    c.customer_name, 
    l.country, 
    l.region, 
    l.city
FROM analytics.norm_customers c
JOIN analytics.norm_sales s ON c.customer_id = s.customer_id
JOIN analytics.norm_locations l ON s.city_id = l.city_id;


--Q2: Do we have customers who have never placed an order?
--We use a LEFT JOIN to find records in the customers table that have no matching records in the sales table.

SELECT c.customer_name
FROM analytics.norm_customers c
LEFT JOIN analytics.norm_sales s ON c.customer_id = s.customer_id
WHERE s.sale_id IS NULL;

/*
Q3: Why does joining orders increase the number of rows?
Answer: This happens due to the One-to-Many (1:N) relationship and how SQL JOIN operations work (specifically Cartesian products on matches). If a single order contains multiple distinct products, joining the main order record with the order items will duplicate the main order's data for every single product. One order with five products results in five rows.
*/

--Q4: What products were sold, to whom, and where?

SELECT 
    p.product_name, 
    c.customer_name, 
    l.city, 
    l.country
FROM analytics.norm_sales s
JOIN analytics.norm_products p ON s.product_id = p.product_id
JOIN analytics.norm_customers c ON s.customer_id = c.customer_id
JOIN analytics.norm_locations l ON s.city_id = l.city_id;

--Q5: Total revenue by country.

SELECT 
    l.country, 
    SUM(s.quantity * p.product_price) AS total_revenue
FROM analytics.norm_sales s
JOIN analytics.norm_locations l ON s.city_id = l.city_id
JOIN analytics.norm_products p ON s.product_id = p.product_id
GROUP BY l.country
ORDER BY total_revenue DESC;


--Q6: Do we have customers without a specified city?
--Architectural flaw reminder: Customers aren't linked to cities in norm_customers. Therefore, a customer without a city is technically any customer who hasn't made a purchase, or a purchase record where city_id is missing.

SELECT c.customer_name
FROM analytics.norm_customers c
LEFT JOIN analytics.norm_sales s ON c.customer_id = s.customer_id
WHERE s.city_id IS NULL;