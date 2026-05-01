USE bank;
CREATE VIEW risk_base AS
SELECT 
	credit_id,
    country,
    end_of_period,
    disbursed_amount,
    repaid_to_ida,
    due_to_ida,
    ROUND(repaid_to_ida / disbursed_amount,4) as repayment_rate,
    ROUND(due_to_ida / disbursed_amount,4) as due_ratio,
    CASE
        WHEN disbursed_amount = 0 THEN 'No Loan'
        WHEN due_to_ida = 0 THEN 'Low Risk'
        WHEN due_to_ida / disbursed_amount <= 0.2 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_segment
FROM banking_clean
WHERE disbursed_amount > 0;
SELECT * FROM risk_base;
-- ======================================
-- 🎯 Q1: Where is the money going?
SELECT 
	country,
    SUM(disbursed_amount) as total_disbursed
FROM banking_clean
GROUP BY country
ORDER BY total_disbursed DESC
LIMIT 10;
-- ==================================
-- 🎯 Q2: Who is not paying back?
SELECT 
	country,
    AVG(due_ratio) AS avg_due_ratio,
    COUNT(*) AS records
FROM risk_base
WHERE due_ratio > 0
GROUP BY country
ORDER BY avg_due_ratio DESC
LIMIT 10;
-- ==================================
-- 🎯 Q3: Which loans are risky?
SELECT 
	risk_segment,
    COUNT(*) AS total_loans,
    ROUND(COUNT(*) * 100/SUM(COUNT(*)) OVER(),2) AS percentage
FROM risk_base
GROUP BY risk_segment;
-- ==================================
-- 💥 BONUS (makes your project stand out)

WITH country_risk_counts AS (
    SELECT
        country,
        risk_segment,
        COUNT(*) AS cnt
    FROM risk_base
    GROUP BY country, risk_segment
),

ranked AS (
    SELECT
        country,
        risk_segment,
        cnt,
        ROW_NUMBER() OVER (
            PARTITION BY country
            ORDER BY cnt DESC
        ) AS rn
    FROM country_risk_counts
)

SELECT
    country,
    risk_segment AS dominant_risk_segment,
    cnt
FROM ranked
WHERE rn = 1
ORDER BY cnt DESC;
