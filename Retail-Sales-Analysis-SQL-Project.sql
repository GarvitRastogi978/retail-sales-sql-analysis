-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p2;

-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

SELECT * FROM retail_sales
LIMIT 10

SELECT COUNT(*) 
FROM retail_sales

-- Data Cleaning
SELECT * FROM retail_sales
WHERE transaction_id IS NULL

SELECT * FROM retail_sales
WHERE sale_date IS NULL

SELECT * FROM retail_sales
WHERE sale_time IS NULL

SELECT * FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

-- 
DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
-- Data Exploration
-- How many sales we have?
SELECT COUNT (*) as total_sales FROM retail_sales

-- How many uniuque customers we have ?
SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales

SELECT DISTINCT category FROM retail_sales


-- Data Analysis & Business Key Problems & Answers
-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category, SUM(total_sale) as net_sale, COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT ROUND(AVG(age),2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT *
FROM retail_sales
WHERE total_sale > 1000

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT category, gender, COUNT(*) as total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY 1

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT year, month, avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1
-- ORDER BY 1, 3 DESC

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT customer_id, SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
WITH hourly_sale
AS
(
SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Aftrernoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales
)
SELECT shift, COUNT(*) as total_orders 
FROM hourly_sale
GROUP BY shift
 
-- END OF PROJECT

--EXTRA Analysis & Findings
--Business Problem 12: Which customer age group (e.g., 18-25, 26-35, 36-45, 46-55, 56+) generates the highest total revenue?
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        WHEN age >= 56 THEN '56+'
        ELSE 'Unknown'
    END AS age_group,
    SUM(total_sale) AS total_revenue
FROM retail_sales
WHERE age IS NOT NULL -- Exclude records with missing age
GROUP BY age_group
ORDER BY total_revenue DESC;

--Business Problem 14: Who are the top 10 customers (by customer_id) based on their total lifetime spending?
SELECT 
    customer_id,
    SUM(total_sale) AS lifetime_value
FROM retail_sales
GROUP BY customer_id
ORDER BY lifetime_value DESC
LIMIT 10;
--Interpretation:This list shows the 10 customers who have spent the most money. The business can prioritize these customers for exclusive offers, early access to new products, or dedicated customer service to ensure retention.

--Business Problem 15: What is the distribution of sales across different times of the day (e.g., Morning, Afternoon, Evening, Night)?
--This helps in optimizing staffing, promotions, and store hours.
SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 6 AND 11 THEN 'Morning (6 AM - 11 AM)'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon (12 PM - 5 PM)'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 18 AND 21 THEN 'Evening (6 PM - 9 PM)'
        ELSE 'Night (10 PM - 5 AM)'
    END AS time_of_day,
    COUNT(*) AS number_of_transactions,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY time_of_day
ORDER BY total_sales DESC;

--END.