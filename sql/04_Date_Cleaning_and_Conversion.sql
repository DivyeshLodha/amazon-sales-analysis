-- ============================================================================
-- AMAZON SALES ANALYSIS
-- DATE CLEANING AND CONVERSION
-- Purpose: Reviews missing shipping and return dates and converts text date fields to DATE columns.
-- Database: amazon_sales
-- ============================================================================

-- Check missing return dates

SELECT
    COUNT(*) AS total_shipping_records,
    SUM(return_date IS NULL) AS missing_return_dates
FROM shipping;

select count(*),
sum(trim(return_date) = '') as 'missing dates'
from shipping
;

-- Count NULLs, blanks, and filled dates separately

SELECT
    COUNT(*) AS total_shipping_records,

    SUM(return_date IS NULL) AS missing_null_dates,

    SUM(TRIM(return_date) = '') AS missing_blank_dates,

    SUM(return_date IS NOT NULL
        AND TRIM(return_date) <> '') AS filled_return_dates

FROM shipping;

-- Total Missing return Dates

SELECT
    COUNT(*) AS total_shipping_records,
    SUM(
        return_date IS NULL
        OR TRIM(return_date) = ''
    ) AS missing_return_dates
FROM shipping;

DESCRIBE shipping   ;

-- Missing and return dates
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

SELECT shipping_date, return_date
FROM shipping
LIMIT 20;

DESCRIBE shipping;

-- Convert text dates into proper DATE columns
ALTER TABLE shipping
ADD COLUMN shipping_date_new DATE NULL, -- ADDING NEW COLUMNS
ADD COLUMN return_date_new DATE NULL;

-- Convert text dates into proper DATE columns

UPDATE shipping
SET
    shipping_date_new =
        STR_TO_DATE(
            NULLIF(TRIM(shipping_date), ''),
            '%Y-%m-%d'
        ),
    return_date_new =
        STR_TO_DATE(
            NULLIF(TRIM(return_date), ''),
            '%Y-%m-%d'
        );

-- verify the converted dates:
SELECT
    shipping_date,
    shipping_date_new,
    return_date,
    return_date_new
FROM shipping
LIMIT 20;

-- Check whether the conversion succeeded
SELECT
    COUNT(*) AS total_records,
    SUM(shipping_date_new IS NULL) AS missing_shipping_dates,
    SUM(return_date_new IS NULL) AS missing_return_dates
FROM shipping;

-- Now check whether any nonblank text dates failed to convert:
SELECT
    shipping_id,
    shipping_date,
    shipping_date_new,
    return_date,
    return_date_new
FROM shipping
WHERE
    (TRIM(COALESCE(shipping_date, '')) <> ''
     AND shipping_date_new IS NULL)
OR
    (TRIM(COALESCE(return_date, '')) <> ''
     AND return_date_new IS NULL);

-- Replace the old columns
ALTER TABLE shipping
DROP COLUMN shipping_date,
DROP COLUMN return_date;

-- change column

ALTER TABLE shipping
CHANGE COLUMN shipping_date_new shipping_date DATE NULL,
CHANGE COLUMN return_date_new return_date DATE NULL;

-- check data type

DESCRIBE shipping;

SELECT * FROM shipping;
