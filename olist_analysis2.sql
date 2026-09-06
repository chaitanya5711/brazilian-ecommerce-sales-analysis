USE olist_ecommerce;

#Step 11 — Top Products by Revenue

SELECT
    product_id,
    product_category_name AS category,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(*) AS items_sold,
    ROUND(AVG(price), 2) AS average_price
FROM olist_sales_analysis
WHERE product_id IS NOT NULL
GROUP BY product_id, product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

#Step 11.1 — Top Products by Number of Items Sold

SELECT
    product_id,
    product_category_name AS category,
    COUNT(*) AS items_sold,
    ROUND(SUM(price), 2) AS total_revenue
FROM olist_sales_analysis
WHERE product_id IS NOT NULL
GROUP BY product_id, product_category_name
ORDER BY items_sold DESC
LIMIT 10;


#Step 12 — Final SQL Business Summary

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    ROUND(SUM(price), 2) AS total_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight,
    ROUND(AVG(price), 2) AS avg_item_price,
    ROUND(
        SUM(price) / COUNT(DISTINCT order_id),
        2
    ) AS avg_order_value,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM olist_sales_analysis;