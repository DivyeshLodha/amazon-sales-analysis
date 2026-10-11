-- ============================================================================
-- AMAZON SALES ANALYSIS
-- DATABASE AND TABLE SETUP
-- Purpose: Creates the amazon_sales database and defines the project tables and relationships.
-- Database: amazon_sales
-- ============================================================================

CREATE DATABASE IF NOT EXISTS amazon_sales;
SET FOREIGN_KEY_CHECKinventoryS = 0;

USE amazon_sales;

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL
);

CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(150) NOT NULL,
    origin VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    seller_id INT NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_per_unit DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

CREATE TABLE shipping (
    shipping_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    shipping_date varchar(30),
    return_date varchar(30),
    shipping_provider VARCHAR(50) NOT NULL,
    delivery_status VARCHAR(30) NOT NULL,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    stock INT NOT NULL,
    warehouse_id INT NOT NULL,
    last_stock_date DATE NOT NULL,
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
