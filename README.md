# Amazon Products Insights using SQL

End-to-end SQL analytics project: 9 raw CSV files turned into a MySQL data model, 10 business queries, KPIs, insights and recommendations.

## Project status
- Completed project: fully functional and properly presented
- GitHub repository: code uploaded and ready
- LinkedIn post: done

## Why this project
I chose this project because Amazon is a large e-commerce platform that generates a huge amount of sales and customer data. I wanted to understand how SQL can be used to analyze this data, identify business problems, and discover opportunities for improvement. Through this project, I aimed to improve my practical SQL skills in data cleaning, joins, aggregations, and business analysis, while converting raw data into meaningful insights that can support better business decisions.

## Dataset
9 related tables covering customers, products, categories, sellers, orders, order items, inventory, payments and shipping.

| Table | Rows | Role |
|---|---|---|
| customers | 898 | Master |
| products | 765 | Master |
| sellers | 54 | Master |
| category | 6 | Reference |
| orders | 21,629 | Transaction |
| order_items | 21,629 | Transaction |
| inventory | 765 | Operational |
| payments | 21,629 | Operational |
| shipping | 21,141 | Operational |

Orders cover 2020-01-01 to 2024-07-30.

## Data model
Primary and foreign keys were checked against the data: all 8 foreign keys resolve with no orphan records.
- customers 1:N orders, sellers 1:N orders, category 1:N products, products 1:N order_items
- orders 1:N order_items (one item row per order in this data)
- products 1:1 inventory, orders 1:1 payments, orders 1:0..1 shipping (488 cancelled orders have no shipping row)

## Business questions answered
1. Which product categories generate the most revenue?
2. Which products are the best sellers by revenue?
3. Which states bring in the most revenue?
4. What share of payments succeed, are refunded or fail?
5. Which products have a return rate above 20%?
6. How many customers have never placed an order?
7. Which products are running low on stock?
8. Which products have never been sold?
9. How has revenue changed year over year?
10. Who are the most valuable customers (historical CLTV)?

## Key findings
- Total combined revenue is $12.64M across all order statuses; completed orders account for $10.38M.
- Electronics generates 89.63% of completed revenue.
- Ohio and Texas generate 90.2% of completed revenue.
- 12.79% of units were returned; 12 products with 50+ units sold have return rates above 20%.
- 212 customers (23.6%) have never placed an order.
- Order volume falls about 65% in 2024. The data ends 30 Jul 2024, so this needs checking: real decline or incomplete data?

## Data quality issues found and handled
Dates stored as text, trailing spaces in status labels, column names with spaces, label typos, inconsistent text case, duplicate product names (queries group by `product_id`), blank values instead of NULL, flat order lines, payment date equal to order date, missing registration date, implausible margins and possible duplicate customers.

## SQL techniques used
SELECT, WHERE, ORDER BY, LIMIT, SUM, COUNT, AVG, GROUP BY, HAVING, INNER JOIN, LEFT JOIN, CTEs, CASE, window functions (LAG, RANK), TRIM, NULL handling, datatype conversion and date functions.

## Repository structure
```
amazon-products-insights-sql/
├── README.md
├── data/                     # the 9 CSV files
├── sql/
│   ├── 01_Database_and_Tables.sql      # MySQL_Implementation.sql
│   └── 02_Row_Count_Validation.sql       # Amazon_SQL_Insights.sql
        03_Data_Quality_Checks.sql
        04_Date_Cleaning_and_Conversion.sql
        05_Status_and_Name_Standardization.sql
        06_Business_Insights.sql
└── presentation/
    └── Amazon_SQL_Insights_Final.pptx
```

## How to run
1. Install MySQL 8.0 and MySQL Workbench.
2. Put the CSV files in one folder and update the folder path in `sql/01_schema_load_clean.sql`.
3. Run `sql/01_schema_load_clean.sql` step by step (staging tables, typed tables, cleaning, validation).
4. Run `sql/02_business_queries.sql` to reproduce the 10 results.

## Tools
MySQL 8.0, SQL, MySQL Workbench, PowerPoint.

## Author
Divyesh Lodha, Data Analyst
