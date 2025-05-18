-- Assessment_Q3.sql
-- Find active accounts with no inflow transactions in the last 365 days

WITH plan_last_activity AS (
    -- Get last transaction date for each plan from savings (deposits)
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        p.created_on,
        MAX(s.transaction_date) AS last_transaction_date
    FROM 
        plans_plan p
    LEFT JOIN 
        savings_savingsaccount s ON p.id = s.plan_id 
        AND s.transaction_status = 'success'  -- Only successful transactions
        AND s.confirmed_amount > 0  -- Positive inflow
    WHERE 
        p.is_deleted = 0 
        AND p.is_archived = 0
        AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)  -- Only savings/investment plans
    GROUP BY 
        p.id, p.owner_id, p.created_on
)
SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
    END AS type,
    pla.last_transaction_date,
    DATEDIFF(CURRENT_DATE, COALESCE(pla.last_transaction_date, p.created_on)) AS inactivity_days
FROM 
    plans_plan p
JOIN 
    plan_last_activity pla ON p.id = pla.plan_id
WHERE 
    -- Accounts with no inflows OR last inflow > 365 days ago
    (pla.last_transaction_date IS NULL AND DATEDIFF(CURRENT_DATE, p.created_on) > 365)
    OR 
    (pla.last_transaction_date IS NOT NULL AND DATEDIFF(CURRENT_DATE, pla.last_transaction_date) > 365)
ORDER BY 
    inactivity_days DESC;