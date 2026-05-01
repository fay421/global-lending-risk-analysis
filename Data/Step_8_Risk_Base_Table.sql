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
-- ======================================
SELECT risk_segment, 
	   COUNT(*) as cnt
FROM risk_base
GROUP BY risk_segment;
    
    
