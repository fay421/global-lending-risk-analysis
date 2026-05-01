USE bank;

-- =========================================================
-- STEP 3: DATA INSPECTION
-- Checks:
-- 1. Row count
-- 2. Null values
-- 3. Duplicate business keys
-- 4. Duplicate summary check
-- 5. Data types (dates & numerics)
-- 6. Date conversion test
-- 7. Final cleaning (dedup + conversion)
-- 8. Strange negative values or zeros
-- =========================================================


-- =========================================================
-- 1. ROW COUNT
-- =========================================================
SELECT COUNT(*) AS total_rows
FROM banking_raw;
-- Result: 11330


-- =========================================================
-- 2. NULL CHECK
-- COUNT(*) = all rows
-- COUNT(column) = non-null rows
-- NULLs = total rows - non-null rows
-- =========================================================
SELECT 
    COUNT(*) AS total_rows,
    COUNT(Credit_Number) AS non_null_values,
    COUNT(*) - COUNT(Credit_Number) AS null_count
FROM banking_raw;
-- Result: 0 NULLs

-- Alternative method
SELECT 
    SUM(CASE WHEN Credit_Number IS NULL THEN 1 ELSE 0 END) AS null_count
FROM banking_raw;
-- Result: 0


-- =========================================================
-- 3. DUPLICATE CHECK (BUSINESS KEY LEVEL)
-- Check duplicate records based on Credit_Number + End_of_Period
-- =========================================================
SELECT 
    Credit_Number,
    End_of_Period,
    COUNT(*) AS cnt
FROM banking_raw
GROUP BY Credit_Number, End_of_Period
HAVING COUNT(*) > 1;

-- Insight:
-- Duplicate business keys exist and need investigation


-- =========================================================
-- 4. DUPLICATE SUMMARY CHECK
-- Compare total rows vs unique business-key combinations
-- =========================================================
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Credit_Number, End_of_Period) AS unique_rows
FROM banking_raw;

-- Insight:
-- If total_rows = 2 × unique_rows, the dataset is duplicated twice


-- =========================================================
-- 5. DATA TYPE CHECK
-- =========================================================
DESCRIBE banking_raw;

-- Insight:
-- Date columns are stored as VARCHAR (text) → need conversion
-- Numeric columns are also stored as VARCHAR → need conversion


-- =========================================================
-- 6. DATE CONVERSION TEST
-- Convert text to DATE/DATETIME using STR_TO_DATE
-- =========================================================
SELECT 
    STR_TO_DATE(End_of_Period, '%m/%d/%Y %H:%i') AS End_of_Period,
    STR_TO_DATE(First_Repayment_Date, '%m/%d/%Y %H:%i') AS First_Repayment_Date,
    STR_TO_DATE(Last_Repayment_Date, '%m/%d/%Y %H:%i') AS Last_Repayment_Date,
    STR_TO_DATE(Agreement_Signing_Date, '%m/%d/%Y %H:%i') AS Agreement_Signing_Date,
    STR_TO_DATE(Board_Approval_Date, '%m/%d/%Y %H:%i') AS Board_Approval_Date
FROM banking_raw
LIMIT 10;

-- Insight:
-- Conversion works, so these fields can be used in the cleaning step


-- =========================================================
-- 7. FINAL CLEANING (DEDUP + DATE + NUMERIC CONVERSION)
-- Keep one row per Credit_Number + End_of_Period
-- =========================================================
WITH dedup AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Credit_Number, End_of_Period
               ORDER BY End_of_Period
           ) AS rn
    FROM banking_raw
),
clean_banking AS (
    SELECT
        STR_TO_DATE(End_of_Period, '%m/%d/%Y %H:%i') AS End_of_Period,
        Credit_Number,
        Country,
        Region,
        CAST(Disbursed_Amount AS DECIMAL(18,2)) AS Disbursed_Amount,
        CAST(Repaid_to_IDA AS DECIMAL(18,2)) AS Repaid_to_IDA,
        CAST(Due_to_IDA AS DECIMAL(18,2)) AS Due_to_IDA
    FROM dedup
    WHERE rn = 1
)
SELECT *
FROM clean_banking;


-- =========================================================
-- 8. CHECK STRANGE NEGATIVE VALUES OR ZEROS
-- Small negative Due_to_IDA values are treated as 0
-- because they likely come from rounding errors
-- =========================================================
SELECT 
    Credit_Number,
    End_of_Period,
    CAST(Due_to_IDA AS DECIMAL(18,2)) AS Due_to_IDA_original,
    CASE 
        WHEN CAST(Due_to_IDA AS DECIMAL(18,2)) BETWEEN -1 AND 0 THEN 0
        ELSE CAST(Due_to_IDA AS DECIMAL(18,2))
    END AS Due_to_IDA_clean
FROM banking_raw;




