USE bank;
-- ====== Check for record per credit ===========
-- SELECT credit_id,
--        COUNT(end_of_period) as cnt
-- FROM banking_clean
-- GROUP BY credit_id 
-- HAVING cnt > 1;      
-- ==== Latest record per credit =====
DROP TABLE banking_latest;
CREATE TABLE banking_latest AS

WITH ranking AS(
				SELECT *,
                ROW_NUMBER() OVER( PARTITION BY credit_id
                ORDER BY end_of_period DESC ) AS rn
                FROM banking_clean)
SELECT * 
FROM ranking
WHERE rn = 1;
-- ====== Check for closed loans still showing balances ===========                
SELECT credit_id,
       credit_status,
       due_to_ida,
       repaid_to_ida
FROM banking_latest
WHERE credit_status = 'Fully Repaid'
  AND due_to_ida > 0.1; 
-- ====== Check for disbursed greater than principal ===========
SELECT credit_id,
       original_principal_amount,
       disbursed_amount,
       disbursed_amount - original_principal_amount AS diff
FROM banking_latest
WHERE disbursed_amount > original_principal_amount
ORDER BY diff DESC;
-- ====== Check for repaid greater than disbursed ===========
SELECT
    credit_id,
    disbursed_amount - original_principal_amount AS additional_funding,
    (disbursed_amount / NULLIF(original_principal_amount,0)) AS expansion_ratio
FROM banking_latest;
-- ================= FOR KPI'S ============
SELECT 
    CASE 
        WHEN disbursed_amount < original_principal_amount THEN 'Under Utilized'
        WHEN disbursed_amount = original_principal_amount THEN 'Fully Utilized'
        ELSE 'Expanded'
    END AS loan_type,
    COUNT(*) AS count_loans
FROM banking_latest
GROUP BY loan_type;
-- ================




