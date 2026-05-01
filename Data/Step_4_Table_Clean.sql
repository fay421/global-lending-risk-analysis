USE bank;

-- =========================================================
-- STEP 4: BUILD A CLEASE BASE TABLE
CREATE TABLE banking_clean AS
SELECT
	
    Credit_Number AS credit_id,
    Country,
    Country_Code,
    Credit_Status,
    Original_Principal_Amount,
    Due_to_IDA,
    Borrowers_Obligation,
    -- ✅ safe date conversion
    CASE 
        WHEN End_of_Period IS NULL OR TRIM(End_of_Period) = '' THEN NULL
        ELSE STR_TO_DATE(End_of_Period, '%m/%d/%Y %H:%i')
    END AS end_of_period,

    CASE 
        WHEN First_Repayment_Date IS NULL OR TRIM(First_Repayment_Date) = '' THEN NULL
        ELSE STR_TO_DATE(First_Repayment_Date, '%m/%d/%Y %H:%i')
    END AS first_repayment_date,

    -- cleaned numbers
    CAST(Disbursed_Amount AS DECIMAL(18,2)) AS disbursed_amount,
    CAST(Repaid_to_IDA AS DECIMAL(18,2)) AS repaid_to_ida,

    -- cleaning rule
    CASE 
        WHEN Disbursed_Amount < 0 THEN NULL
        ELSE Disbursed_Amount
    END AS disbursed_clean

FROM banking_raw
WHERE Credit_Number IS NOT NULL;