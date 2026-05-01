USE bank;
-- Step 1. Identify the grain
-- First confirm:
-- one row = one Credit Number at one End of Period
-- This is critical.
-- Ask:
-- 1-can one credit appear many times across different End of Period values?
-- 2-are amounts cumulative snapshots or one-time transactions?
-- This decides all later SQL logic.
--------------
SELECT DISTINCT(End_of_Period)
FROM banking_raw
ORDER BY End_of_Period;
------------------------------
-- 1-can one credit appear many times across different End of Period values?
SELECT End_of_Period,
       Country_Code,
       Country,
	   Credit_Number,
       COUNT(*) as cnt
FROM banking_raw
GROUP BY End_of_Period,Credit_Number
HAVING cnt > 1;
-----------------------------------------
-- rank number for cleaning duplicated values
WITH dedup AS(
	SELECT *,
       ROW_NUMBER() OVER(PARTITION BY End_of_Period,Credit_Number
       ORDER BY Credit_Number) as rn
	FROM banking_raw)
SELECT *
FROM dedup
WHERE rn = 1;
----------------------------------------
-- 2-are amounts cumulative snapshots or one-time transactions? cumulative
----------------------------------------