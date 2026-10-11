-- ============================================================================
-- AMAZON SALES ANALYSIS
-- ROW COUNT VALIDATION
-- Purpose: Checks the number of records in the project tables after data import.
-- Database: amazon_sales
-- ============================================================================

SELECT 
    COUNT(*) AS rowas
FROM
    orders;

SELECT 
    COUNT(*)
FROM
    categories;
use amazon_sales;
SELECT 
    COUNT(*) categories
FROM
    orders;

SELECT 
    COUNT(*)
FROM
    inventory;

SELECT 'categories' AS table_name, COUNT(*) AS total_rows FROM categories
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'shipping', COUNT(*) FROM shipping
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory;




