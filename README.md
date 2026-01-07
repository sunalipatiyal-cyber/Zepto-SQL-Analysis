🛒 Zepto Inventory & Revenue Optimization (SQL)

📋 Project Overview

This project focuses on analyzing the inventory and pricing strategy of Zepto, a leading Quick-Commerce platform. Using MySQL, I transformed a raw dataset of 1,200+ SKUs into actionable business insights. The project covers the entire data lifecycle: Schema Design, Data Audit, Multi-stage Cleaning, and Strategic Business Analysis.

🛠️ Tech Stack
Language: SQL (MySQL)
Tool: MySQL Workbench
Key Techniques: Data Normalization, CTEs, Window Functions, Aggregate Analysis, Conditional Logic.

Key Features & Analysis
1. Data Integrity & Cleaning
Currency Normalization: Converted pricing from Paise to INR to ensure stakeholder-ready reporting.
Anomaly Removal: Identified and removed 15% data leakage (nulls and zero-price entries) that would have skewed AOV (Average Order Value).

2. Revenue Gap Analysis
Inventory Health: Flagged high-value items (>₹300) that are currently out of stock, representing a 12% potential revenue recovery.

3. Unit Economics & Logistics
Price-per-Gram: Calculated unit pricing to identify "Value" vs. "Premium" products across different pack sizes.
Load Segmentation: Categorized 100% of inventory into Low, Medium, and Bulk buckets using CASE statements to assist logistics in vehicle allocation.

Database Schema
CREATE TABLE zepto (
    sku_id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(10,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(10,2),
    weightInGms INT,
    outOfStock BOOLEAN,
    quantity INT
);

Final Business Recommendations
- Based on the SQL analysis, I proposed the following to the business:
- Procurement Focus: Prioritize restocking the "High-Value" items identified in Query 2 to capture the 12% revenue leakage.
- Marketing Strategy: Leverage the "Traffic Drivers" found in Query 5 for push notifications to increase App Open Rates.
- Logistics Planning: Utilize the weight segmentation from Query 7 to re-allocate delivery vehicles at hubs where "Bulk" inventory exceeds 30% of total stock.
