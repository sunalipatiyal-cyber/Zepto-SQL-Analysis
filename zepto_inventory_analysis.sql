-- STEP - 1 CREATE A DATABASE
CREATE DATABASE zepto_sql_project;

-- USE THAT DATABASE
USE zepto_sql_project;

-- We use 'IF EXISTS' to prevent errors during re-runs.
DROP table if exists zepto;

--  STEP 2: Schema Definition 
-- We define data types strictly to save memory and ensure data integrity.

CREATE TABLE zepto (
    sku_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for every product
    category VARCHAR(120), -- Grouping of products
    name VARCHAR(150) NOT NULL, -- Product name (cannot be empty)
    mrp DECIMAL(8,2), -- Maximum Retail Price (Total 8 digits, 2 after decimal)
    discountPercent DECIMAL(5,2), -- Percentage (e.g., 15.50%)
    availableQuantity INT, -- Current stock count
    discountedSellingPrice DECIMAL(8,2), -- Final price after discount
    weightInGms INT,-- Metric for unit analysis
    outOfStock VARCHAR(10), 
    quantity INT -- Pack size (e.g., 1 for single, 6 for pack)
);

-- INSERTING THE DATA (table data wizard)

-- DATA EXPLORATION

-- 1. The Row Count (Sanity Check)
 -- Purpose: To ensure the data import was successful.
select count(*)
from zepto;

-- 2. The Sample View (Data Profiling)
-- Purpose: To understand the data (Are names in CAPS? Are prices formatted correctly?)
SELECT * FROM zepto
LIMIT 10;

-- 3. Null Value Check (Data Integrity)
-- What would be the strategy if 20% of the categories are NULL?
-- first try to 'backfill' them by looking at the product names (e.g., if the name is 'Milk', assign 'Dairy').
-- If I can't, I would label them 'Uncategorized' so they don't skew the specific category averages.
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

-- ANOTHER METHOD TO FIND THE NULL VALUES

SELECT 
  COUNT(*) AS total_rows,

  COUNT(name) AS non_null_name,
  COUNT(category) AS non_null_category,
  COUNT(mrp) AS non_null_mrp,
  COUNT(discountPercent) AS non_null_discountPercent,
  COUNT(discountedSellingPrice) AS non_null_discountedSellingPrice,
  COUNT(weightInGms) AS non_null_weightInGms,
  COUNT(availableQuantity) AS non_null_availableQuantity,
  COUNT(outOfStock) AS non_null_outOfStock

FROM zepto;

-- 4. Unique Categories (Domain Knowledge)
--  Purpose: To see the "breadth" of the business
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- PRODUCT IN STOCK V/S OUT OF STOCK
-- Purpose: To see if the store looks "empty" to a customer.
-- In MySQL, BOOLEAN is 0 (In Stock) or 1 (Out of Stock).
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

-- 6. Duplicate Detection
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING count(sku_id) > 1
ORDER BY count(sku_id) DESC;

-- STEP -2 DATA CLEANING
-- In an e-commerce database, a price of 0 is usually a technical glitch.
-- f you include these in your average price calculations, your results will be artificially low.

-- Step A: Identify the problem
-- products with price = 0
SELECT * FROM zepto
WHERE mrp = 0 
OR
discountedSellingPrice = 0;

-- MySQL Workbench often runs in Safe Update Mode, which prevents DELETE/UPDATE without a KEY column in WHERE.

-- TURNING OFF THE  SAFE MODE

SET SQL_SAFE_UPDATES = 0;

-- Step B: Remove the noise
-- We delete them because a product without a price cannot be sold or analyzed.
-- IMP. = Assigning a 'random' price would be data fabrication. Unless we have a source to verify the correct price'
-- it is safer to remove these records to keep our averages accurate.

DELETE FROM zepto
WHERE mrp = 0;

-- 2. Currency Normalization (Paise to Rupees)
-- Normalization means bringing all your data into a consistent  format so they can be compared fairly.

UPDATE zepto
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

-- 3. Logical Integrity Check (The "Discount" Trap)
-- Sometimes, the discountedSellingPrice might accidentally be recorded as higher than the mrp.
-- This is a major data error.
-- Check for logical errors

SELECT *
FROM zepto 
WHERE discountedSellingPrice > mrp;
-- If you find these, you would likely set the discountedSellingPrice = mrp (meaning no discount) 
-- or flag it for the engineering team.
SELECT mrp, discountedSellingPrice
FROM zepto;

-- DATA ANALYSIS

-- Revenue & Loss Analysis

-- Q1.What are the Products with High MRP but Out of Stock

SELECT DISTINCT name,mrp
FROM zepto
WHERE outOfStock = TRUE and mrp > 300
ORDER BY mrp DESC;

-- Q2.Calculate Estimated Revenue for each category
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

-- Marketing & Pricing Strategy(The "Customer" Talk)

-- Q3. Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- The Top 3 most discounted products within each category,
 -- I would use a CTE to create a temporary result set and a Window Function like DENSE_RANK()
 WITH CategoryRank AS (
    SELECT name, category, discountPercent,
           DENSE_RANK() OVER(PARTITION BY category ORDER BY discountPercent DESC) as ranking
    FROM zepto
)
SELECT * FROM CategoryRank WHERE ranking <= 3;
 
-- Q4. Identify the top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Unit Economics & Logistics

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7.Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

-- Q8.What is the Total Inventory Weight Per Category 
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;





















