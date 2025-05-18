-- Assessment_Q4.sql
-- Estimate Customer Lifetime Value (CLV) using transaction behavior and account tenure

WITH customer_stats AS (
    -- Step 1: Aggregate key customer metrics
    SELECT 
        u.id AS customer_id,               -- Unique ID for each customer
        u.first_name,
        u.last_name,
        u.date_joined,                     -- Date the customer registered
        COUNT(s.id) AS transaction_count,  -- Total number of successful transactions
        COALESCE(SUM(s.confirmed_amount), 0) AS total_amount_kobo,  -- Total confirmed deposit amount in kobo
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months  -- Duration since signup in months
    FROM 
        users_customuser u
    LEFT JOIN 
        savings_savingsaccount s ON u.id = s.owner_id 
        AND s.transaction_status = 'success'  -- Consider only successful transactions
    GROUP BY 
        u.id, u.first_name, u.last_name, u.date_joined
)

-- Step 2: Calculate CLV using defined formula
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS name,  -- Full customer name
    tenure_months,                               -- Customer lifetime in months
    transaction_count AS total_transactions,     -- Total number of transactions
    ROUND(
        CASE 
            WHEN tenure_months > 0 THEN 
                (total_amount_kobo / 100 * 0.001)  -- Convert kobo to currency and apply 0.1% profit per transaction
                * (transaction_count / tenure_months)  -- Normalize by monthly activity
                * 12  -- Annualize the CLV
            ELSE 0
        END,
        2  -- Round CLV to 2 decimal places
    ) AS estimated_clv
FROM 
    customer_stats
WHERE 
    tenure_months > 0  -- Exclude customers with less than one month of tenure to avoid division by zero
ORDER BY 
    estimated_clv DESC;  -- Rank customers from highest to lowest CLV
