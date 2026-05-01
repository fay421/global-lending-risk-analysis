USE bank;
CREATE VIEW kpi_base AS
SELECT
    credit_id,
    country,
    end_of_period,
    disbursed_amount,
    repaid_to_ida,
    due_to_ida,

    ROUND(repaid_to_ida / disbursed_amount, 4) AS repayment_rate,
    ROUND(due_to_ida / disbursed_amount, 4) AS due_ratio

FROM banking_clean
WHERE disbursed_amount > 0;

SELECT *
FROM kpi_base
LIMIT 50;