-- Assessment_Q4.sql
-- Calculate Customer Lifetime Value estimation

WITH customer_stats AS (
    SELECT 
        u.id AS customer_id,
        u.first_name,
        u.last_name,
        u.date_joined,
        COUNT(s.id) AS transaction_count,
        COALESCE(SUM(s.confirmed_amount), 0) AS total_amount_kobo,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months
    FROM 
        users_customuser u
    LEFT JOIN 
        savings_savingsaccount s ON u.id = s.owner_id 
        AND s.transaction_status = 'success'
    GROUP BY 
        u.id, u.first_name, u.last_name, u.date_joined
)
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS name,
    tenure_months,
    transaction_count AS total_transactions,
    ROUND(
        CASE 
            WHEN tenure_months > 0 THEN 
                (total_amount_kobo / 100 * 0.001) *  -- 0.1% profit per transaction (in currency)
                (transaction_count / tenure_months) * 12  -- Annualized rate
            ELSE 0
        END,
        2
    ) AS estimated_clv
FROM 
    customer_stats
WHERE 
    tenure_months > 0  -- Exclude customers who joined this month
ORDER BY 
    estimated_clv DESC;