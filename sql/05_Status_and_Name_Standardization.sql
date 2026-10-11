-- ============================================================================
-- AMAZON SALES ANALYSIS
-- STATUS AND NAME STANDARDIZATION
-- Purpose: Reviews status and naming variations, standardizes values, and verifies the results.
-- Database: amazon_sales
-- ============================================================================

-- Find the spelling and naming inconsistencies

USE amazon_sales;

-- Check order statuses
SELECT DISTINCT order_status
FROM orders
ORDER BY order_status;

-- Check payment statuses
SELECT DISTINCT payment_status
FROM payments
ORDER BY payment_status;

-- Check delivery statuses
SELECT DISTINCT delivery_status
FROM shipping
ORDER BY delivery_status;

-- Check shipping provider names
SELECT DISTINCT shipping_provider
FROM shipping
ORDER BY shipping_provider;

-- Check category names
SELECT DISTINCT category_name
FROM categories
ORDER BY category_name;

-- Run the cleaning SQL

USE amazon_sales;

-- 1. Remove unwanted spaces from order statuses
UPDATE orders
SET order_status = TRIM(order_status);

-- 2. Standardize order status spelling
UPDATE orders
SET order_status = 'In Progress'
WHERE LOWER(order_status) = 'inprogress';

-- 3. Remove unwanted spaces from payment statuses
UPDATE payments
SET payment_status = TRIM(payment_status);

-- 4. Correct payment status wording
UPDATE payments
SET payment_status = 'Payment Successful'
WHERE LOWER(payment_status) = 'payment successed';

-- 5. Remove unwanted spaces from delivery statuses
UPDATE shipping
SET delivery_status = TRIM(delivery_status);

-- 6. Standardize shipping provider names
UPDATE shipping
SET shipping_provider =
    CASE LOWER(TRIM(shipping_provider))
        WHEN 'bluedart' THEN 'Blue Dart'
        WHEN 'dhl' THEN 'DHL'
        WHEN 'fedex' THEN 'FedEx'
        ELSE TRIM(shipping_provider)
    END;

-- 7. Standardize category names
UPDATE categories
SET category_name =
    CASE LOWER(TRIM(category_name))
        WHEN 'electronics' THEN 'Electronics'
        WHEN 'clothing' THEN 'Clothing'
        WHEN 'home & kitchen' THEN 'Home & Kitchen'
        WHEN 'pet supplies' THEN 'Pet Supplies'
        WHEN 'toys & games' THEN 'Toys & Games'
        WHEN 'sports & outdoors' THEN 'Sports & Outdoors'
        ELSE TRIM(category_name)
    END;

-- Formatting

-- Standardize category names
UPDATE categories
SET category_name =
    CASE LOWER(TRIM(category_name))
        WHEN 'electronics' THEN 'Electronics'
        WHEN 'clothing' THEN 'Clothing'
        WHEN 'home & kitchen' THEN 'Home & Kitchen'
        WHEN 'pet supplies' THEN 'Pet Supplies'
        WHEN 'toys & games' THEN 'Toys & Games'
        WHEN 'sports & outdoors' THEN 'Sports & Outdoors'
        ELSE TRIM(category_name)
    END;
-- Verification

SELECT DISTINCT category_name
FROM categories
ORDER BY category_name;

-- VERIFY ALL NAME
SELECT DISTINCT order_status FROM orders;
SELECT DISTINCT payment_status FROM payments;
SELECT DISTINCT delivery_status FROM shipping;
SELECT DISTINCT shipping_provider FROM shipping;
SELECT DISTINCT category_name FROM categories;

SELECT product_id, product_name
FROM products
ORDER BY product_name;

SELECT customer_id, first_name, last_name
FROM customers
ORDER BY first_name, last_name;
