USE bank;
DROP VIEW IF EXISTS kpi_base;

CREATE VIEW kpi_base AS
SELECT
    credit_id,
    credit_status,
    Country_Code,
    country,
    end_of_period,
    first_repayment_date,
    original_principal_amount,
    disbursed_amount,
    repaid_to_ida,
    due_to_ida,
    borrowers_obligation,

    /* 1. Repayment Rate */
    CASE
        WHEN disbursed_amount > 0 
        THEN repaid_to_ida / disbursed_amount
        ELSE NULL
    END AS repayment_rate,

    /* 2. Due Ratio */
    CASE
        WHEN disbursed_amount > 0 
        THEN due_to_ida / disbursed_amount
        ELSE NULL
    END AS due_ratio,

    /* 3. Obligation Ratio */
    CASE
        WHEN disbursed_amount > 0 
        THEN borrowers_obligation / disbursed_amount
        ELSE NULL
    END AS obligation_ratio,

    /* 4. Loan Type */
    CASE 
        WHEN disbursed_amount < original_principal_amount THEN 'Under Utilized'
        WHEN disbursed_amount = original_principal_amount THEN 'Fully Utilized'
        ELSE 'Expanded'
    END AS loan_type,

    /* 5. Fully Repaid Flag */
    CASE
        WHEN credit_status = 'Fully Repaid' THEN 1
        ELSE 0
    END AS fully_repaid_flag,

    /* 6. Has Due Balance */
    CASE
        WHEN due_to_ida > 0 THEN 1
        ELSE 0
    END AS due_flag

FROM banking_latest;

SELECT * FROM kpi_base LIMIT 20;

SELECT
    repayment_rate,
    due_ratio,
    obligation_ratio,
    loan_type
FROM kpi_base
LIMIT 20;
-- ===============================================
-- 🎯 Conclusion
-- 👉 Your banking_latest table is mostly:
-- ✅ Fully repaid loans
-- That’s why everything looks like:
-- 100% repaid
-- 0% due
-- 0 obligation
-- ❗ Is this wrong?
-- 👉 NO — your code is correct
-- 👉 BUT your dataset (latest snapshot) is biased
-- 💡 Why this is happening
-- 👉 You kept the latest record per credit
-- And in real life:
-- 👉 Many loans end as Fully Repaid
-- So your dataset became:
-- ➡️ “final state of loans”
-- ➡️ mostly completed loans
-- ===============================================


















