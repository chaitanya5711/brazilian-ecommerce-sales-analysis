USE olist_ecommerce;

DROP TABLE IF EXISTS olist_sales_analysis;
DROP TABLE IF EXISTS sales_data;

SHOW TABLES;

SELECT COUNT(*) AS total_rows
FROM olist_sales_analysis;


SELECT *
FROM olist_sales_analysis
LIMIT 10;

USE olist_ecommerce;

SHOW TABLES;
USE olist_ecommerce;

SELECT COUNT(*) AS total_rows
FROM olist_sales_analysis;

SELECT *
FROM olist_sales_analysis
LIMIT 10;

DESCRIBE olist_sales_analysis;


#Step 1 — Overall Business KPIs
USE olist_ecommerce;

ALTER TABLE olist_sales_analysis
CHANGE COLUMN `ï»¿order_id` order_id VARCHAR(50);
USE olist_ecommerce;

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    COUNT(DISTINCT product_id) AS total_products,
    ROUND(SUM(price), 2) AS total_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight,
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM olist_sales_analysis;


#Step 2 — Order Status Analysis

USE olist_ecommerce;

SELECT
    order_status,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0 /
        (SELECT COUNT(DISTINCT order_id)
         FROM olist_sales_analysis),
        2
    ) AS order_percentage
FROM olist_sales_analysis
GROUP BY order_status
ORDER BY total_orders DESC;

#Step 3 — Monthly Revenue Trend 📈
USE olist_ecommerce;

SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(price), 2) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_sales_analysis
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY month;

#Step 4 — Top Product Categories by Revenue
SELECT
    product_category_name AS category,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS items_sold
FROM olist_sales_analysis
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

#Step 5 — Top Customer States by Revenue.
USE olist_ecommerce;

SELECT
    customer_state AS state,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_sales_analysis
WHERE customer_state IS NOT NULL
GROUP BY customer_state
ORDER BY total_revenue DESC
LIMIT 10;


#Step 6 — Top Sellers by Revenue

USE olist_ecommerce;

SELECT
    seller_id,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(AVG(price), 2) AS average_item_price
FROM olist_sales_analysis
WHERE seller_id IS NOT NULL
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;


#Step 7 — Delivery Performance Analysis 

USE olist_ecommerce;

SELECT
    delivery_status,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0 /
        COUNT(DISTINCT CASE
            WHEN order_delivered_customer_date IS NOT NULL
            THEN order_id
        END),
        2
    ) AS percentage
FROM olist_sales_analysis
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status
ORDER BY total_orders DESC;

#Step 7.1 — Average Delivery Time

SELECT
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    MIN(delivery_days) AS fastest_delivery_days,
    MAX(delivery_days) AS longest_delivery_days
FROM olist_sales_analysis
WHERE delivery_days IS NOT NULL;


#Step 8 — Customer Purchase Behavior 

SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_sales_analysis
WHERE customer_unique_id IS NOT NULL
GROUP BY customer_unique_id
ORDER BY total_orders DESC;

#Step 8.1 — One-Time vs Repeat Customers

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM olist_sales_analysis
    WHERE customer_unique_id IS NOT NULL
    GROUP BY customer_unique_id
) AS customer_summary
GROUP BY customer_type
ORDER BY total_customers DESC;


#Step 9 — Review & Customer Satisfaction Analysis ⭐

SELECT
    review_score,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0 /
        SUM(COUNT(DISTINCT order_id)) OVER (),
        2
    ) AS percentage
FROM olist_sales_analysis
WHERE review_score IS NOT NULL
GROUP BY review_score
ORDER BY review_score;

#Step 9.1 — Average Rating
SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM olist_sales_analysis
WHERE review_score IS NOT NULL;

#Step 9.2 — Revenue by Review Score

SELECT
    review_score,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_sales_analysis
WHERE review_score IS NOT NULL
GROUP BY review_score
ORDER BY review_score DESC;

#Step 10 — Freight Cost Analysis

USE olist_ecommerce;

SELECT
    ROUND(SUM(price), 2) AS total_product_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight,
    ROUND(AVG(price), 2) AS average_product_price,
    ROUND(AVG(freight_value), 2) AS average_freight,
    ROUND(
        SUM(freight_value) * 100.0 / SUM(price),
        2
    ) AS freight_to_revenue_percentage
FROM olist_sales_analysis;

#Step 10.1 — Categories with Highest Freight
SELECT
    product_category_name AS category,
    ROUND(SUM(price), 2) AS product_revenue,
    ROUND(SUM(freight_value), 2) AS freight_cost,
    ROUND(
        SUM(freight_value) * 100.0 / SUM(price),
        2
    ) AS freight_percentage
FROM olist_sales_analysis
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
HAVING SUM(price) > 0
ORDER BY freight_percentage DESC
LIMIT 10;