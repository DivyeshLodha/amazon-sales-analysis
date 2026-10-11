-- ============================================================================
-- AMAZON SALES ANALYSIS
-- DATA QUALITY CHECKS
-- Purpose: Checks status values, invalid values, missing dates, duplicate keys, and relationship issues.
-- Database: amazon_sales
-- ============================================================================


set sql_safe_updates =0;

-- dataset contains some status values with trailing spaces, such as Returned  and Refunded .
UPDATE orders
SET order_status = TRIM(order_status);

UPDATE payments
SET payment_status = TRIM(payment_status);

UPDATE shipping
SET delivery_status = TRIM(delivery_status),
    shipping_provider = TRIM(shipping_provider);

-- Check for invalid prices, quantities, and stock

SELECT *
FROM products
WHERE price < 0 OR cogs < 0;

SELECT *
FROM order_items
WHERE quantity <= 0 OR price_per_unit < 0;

SELECT *
FROM inventory
WHERE stock < 0;

-- Check available statuses

SELECT DISTINCT order_status
FROM orders;

SELECT DISTINCT payment_status
FROM payments;

SELECT DISTINCT delivery_status
FROM shipping;

-- Check missing return dates

SELECT
    COUNT(*) AS total_shipping_records,
    SUM(return_date IS NULL) AS missing_return_dates
FROM shipping;

select * from shipping;

-- Check orders without shipping records

SELECT
    o.order_id,
    o.order_status
    FROM orders o
LEFT JOIN shipping s
    ON o.order_id = s.order_id
WHERE s.order_id IS NULL;

-- Duplicate Primary key

SELECT category_id, COUNT(*) AS occurrences
FROM categories
GROUP BY category_id
HAVING COUNT(*) > 1;

SELECT customer_id, COUNT(*) AS occurrences
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS occurrences
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check whether foreign-key references are valid

SELECT p.*
FROM products p
LEFT JOIN categories c
    ON p.category_id = c.category_id
WHERE c.category_id IS NULL;

SELECT return_date
FROM shipping
LIMIT 20;

SELECT
    COUNT(*) AS total_shipping_records,

    SUM(return_date IS NULL) AS missing_null_dates,

    SUM(TRIM(return_date) = '') AS missing_blank_dates,

    SUM(return_date IS NOT NULL
        AND TRIM(return_date) <> '') AS filled_return_dates

FROM shipping;

DESCRIBE shipping;

SELECT
    COUNT(*) AS total_records,
    SUM(
        return_date IS NULL
        OR TRIM(return_date) = ''
    ) AS missing_return_dates,
    SUM(
        return_date IS NOT NULL
        AND TRIM(return_date) <> ''
    ) AS available_return_dates
FROM shipping;
