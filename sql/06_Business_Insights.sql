
-- ============================================================================
-- AMAZON PRODUCTS INSIGHTS USING SQL
-- BUSINESS INSIGHTS AND ANALYSIS
-- Database: amazon_sales
-- ============================================================================


-- TOTAL COMBINED REVENUE
-- Revenue across all order statuses

SELECT
    ROUND(SUM(quantity * price_per_unit), 2) AS total_combined_revenue
FROM order_items;


-- Q1. Which product categories generate the most revenue?
-- Completed orders only

SELECT
    c.category_name,
    COUNT(DISTINCT p.product_id) AS products_in_category,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_revenue
FROM categories c
JOIN products p
    ON c.category_id = p.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;


-- Q2. Which are the top 10 products by completed revenue?

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 10;


-- Q3. Which states generate the most completed revenue?

SELECT
    c.state,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.state
ORDER BY total_revenue DESC
LIMIT 5;


-- Q4. What percentage of payments belong to each payment status?

SELECT
    payment_status,
    COUNT(*) AS total_payments,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM payments),
        2
    ) AS percentage
FROM payments
GROUP BY payment_status
ORDER BY total_payments DESC;


-- Q5. Which products have a return rate above 20%?
-- Consider products with at least 50 units sold

WITH product_returns AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS units_sold,
        SUM(
            CASE
                WHEN o.order_status = 'Returned'
                THEN oi.quantity
                ELSE 0
            END
        ) AS returned_units
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_id,
    product_name,
    units_sold,
    returned_units,
    ROUND(
        100.0 * returned_units / NULLIF(units_sold, 0),
        2
    ) AS return_percentage
FROM product_returns
WHERE units_sold >= 50
  AND 100.0 * returned_units / NULLIF(units_sold, 0) > 20
ORDER BY return_percentage DESC;


-- Q6. How many customers have never placed an order?

SELECT
    COUNT(*) AS never_ordered_customers
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- Q7. Which products have low inventory?
-- Low stock means fewer than 10 units

SELECT
    p.product_id,
    p.product_name,
    i.stock
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
WHERE i.stock < 10
ORDER BY i.stock, p.product_name;


-- Q8. Which products have never been sold?

SELECT
    p.product_id,
    p.product_name,
    p.price
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL
ORDER BY p.price DESC;


-- Q9. How has completed revenue changed year over year?
-- LAG() retrieves the previous year's revenue


WITH yearly AS (
    SELECT
        YEAR(o.order_date) AS yr,
        SUM(oi.quantity * oi.price_per_unit) AS revenue
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY YEAR(o.order_date)
)
SELECT
    yr,
    revenue,
    LAG(revenue) OVER (ORDER BY yr) AS prev_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY yr))
        / LAG(revenue) OVER (ORDER BY yr),
        1
    ) AS growth_pct
FROM yearly;


-- Q10. Who are the most valuable customers?
-- Historical CLTV: cumulative completed revenue per customer

WITH customer_cltv AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.price_per_unit) AS cltv
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        cltv,
        RANK() OVER (ORDER BY cltv DESC) AS cltv_rank
    FROM customer_cltv
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.state,
    r.cltv,
    r.cltv_rank,
    (SELECT ROUND(AVG(cltv), 2) FROM customer_cltv)
        AS average_cltv
FROM ranked_customers r
JOIN customers c
    ON r.customer_id = c.customer_id
ORDER BY r.cltv_rank
LIMIT 5;


-- ADDITIONAL Q11. How does completed revenue change month by month?

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS completed_orders
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;


-- ADDITIONAL Q12. How many shipping records have a return date?

SELECT
    COUNT(*) AS total_shipping_records,
    SUM(return_date IS NOT NULL) AS records_with_return_date,
    SUM(return_date IS NULL) AS records_without_return_date,
    ROUND(
        100.0 * SUM(return_date IS NOT NULL) / COUNT(*),
        2
    ) AS percentage_with_return_date
FROM shipping;


-- ADDITIONAL Q13. How many orders have a recorded return date?

SELECT
    COUNT(DISTINCT order_id) AS returned_orders,
    ROUND(
        100.0 * COUNT(DISTINCT order_id) /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage_of_all_orders
FROM shipping
WHERE return_date IS NOT NULL;


-- ADDITIONAL Q14. Which customers generate the highest revenue?
-- Completed orders only

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.state,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_revenue
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
ORDER BY total_revenue DESC
LIMIT 10;


-- ADDITIONAL Q15. Which sellers generate the highest revenue?
-- Completed orders only

SELECT
    s.seller_id,
    s.seller_name,
    s.origin,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_revenue
FROM sellers s
JOIN orders o
    ON s.seller_id = o.seller_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY s.seller_id, s.seller_name, s.origin
ORDER BY total_revenue DESC;


-- ADDITIONAL Q16. What is the average order value (AOV)?
-- Completed revenue divided by completed orders

SELECT
    ROUND(
        SUM(oi.quantity * oi.price_per_unit) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';


-- ADDITIONAL Q17. Which products generate the highest estimated profit?
-- Completed orders only

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
    ) AS estimated_gross_profit
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY estimated_gross_profit DESC
LIMIT 10;
