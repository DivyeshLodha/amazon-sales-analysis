-- ============================================================================
-- AMAZON SALES ANALYSIS
-- BUSINESS INSIGHTS AND ANALYSIS
-- Purpose: Contains SQL queries for sales, products, customers, regions, sellers, returns, payments, and profitability.
-- Database: amazon_sales
-- ============================================================================

-- Total Combined revenue
SELECT
    ROUND(SUM(quantity * price_per_unit), 2) AS total_sales_revenue
FROM order_items;

-- 1 Which product categories generate the most sales?

SELECT
    c.category_name,
    COUNT(DISTINCT p.product_id) AS products_in_category,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_sales
FROM categories c
JOIN products p
    ON c.category_id = p.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.category_id, c.category_name
ORDER BY total_sales DESC;

-- 2 What are the top 10 best-selling products by sales value?

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_sales
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC
LIMIT 10;

-- 3 Which customers generate the highest sales?

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.state,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.state
ORDER BY total_sales DESC
LIMIT 10;

-- 4 Top states
SELECT
    c.state,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.state
ORDER BY total_sales DESC;

-- 5 Top sellers

SELECT
    s.seller_id,
    s.seller_name,
    s.origin,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_sales
FROM sellers s
JOIN orders o
    ON s.seller_id = o.seller_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY s.seller_id, s.seller_name, s.origin
ORDER BY total_sales DESC;

-- 6 Cusotmers with no Orders

SELECT COUNT(*) AS never_ordered_customers
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
WHERE o.order_id IS NULL;

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS monthly_sales,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;

-- 7 How many orders have a recorded return date?

SELECT
    COUNT(*) AS total_shipping_records,
    SUM(return_date IS NOT NULL) AS records_with_return_date,
    SUM(return_date IS NULL) AS records_without_return_date,
    ROUND(
        SUM(return_date IS NOT NULL) * 100.0 / COUNT(*), 2
    ) AS percentage_with_return_date
FROM shipping;

-- 8 PAYMENT status

SELECT
    payment_status,
    COUNT(*) AS total_payments
FROM payments
GROUP BY payment_status
ORDER BY total_payments DESC;

-- 9 Average order value AOV
SELECT
    ROUND(
        SUM(quantity * price_per_unit) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM order_items;

-- 10 How many orders have been returned, and what percentage do they represent?

SELECT
    COUNT(DISTINCT order_id) AS returned_orders,
    ROUND(
        100.0 * COUNT(DISTINCT order_id) /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS returned_order_percentage
FROM shipping
WHERE return_date IS NOT NULL;

-- Q TOP products

SELECT
    p.product_id,
    p.product_name,
    ROUND(
        SUM(oi.quantity * oi.price_per_unit), 2
    ) AS total_revenue,
    ROUND(
        SUM(oi.quantity * p.cogs), 2
    ) AS total_cost,
    ROUND(
        SUM(oi.quantity * (oi.price_per_unit - p.cogs)), 2
    ) AS estimated_profit
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY estimated_profit DESC
LIMIT 10;
