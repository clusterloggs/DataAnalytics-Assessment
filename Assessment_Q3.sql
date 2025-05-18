-- Assessment_Q3.sql
-- Find active savings or investment accounts with no inflow transactions in the last 365 days

WITH plan_last_activity AS (
    -- Step 1: Get the last successful deposit (inflow) transaction for each plan
    SELECT 
        p.id AS plan_id,               -- Unique identifier for the plan
        p.owner_id,                   -- Customer who owns the plan
        p.created_on,                 -- Date the plan was created
        MAX(s.transaction_date) AS last_transaction_date  -- Most recent successful deposit
    FROM 
        plans_plan p
    LEFT JOIN 
        savings_savingsaccount s ON p.id = s.plan_id 
        AND s.transaction_status = 'success'    -- Consider only successful transactions
        AND s.confirmed_amount > 0              -- Ensure it's a positive inflow
    WHERE 
        p.is_deleted = 0                         -- Include only active (not deleted) plans
        AND p.is_archived = 0                    -- Exclude archived plans
        AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)  -- Filter for savings or investment plans
    GROUP BY 
        p.id, p.owner_id, p.created_on           -- Group by each plan to get the latest activity
)

-- Step 2: Identify plans with no recent inflow in the past 365 days
SELECT 
    p.id AS plan_id,                              -- Plan ID
    p.owner_id,                                   -- Customer ID
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'    -- Label the plan type
        WHEN p.is_a_fund = 1 THEN 'Investment'
    END AS type,
    pla.last_transaction_date,                    -- Last known deposit date (NULL if none)
    DATEDIFF(CURRENT_DATE, COALESCE(pla.last_transaction_date, p.created_on)) AS inactivity_days
        -- Calculate inactivity period using last inflow or plan creation date as fallback
FROM 
    plans_plan p
JOIN 
    plan_last_activity pla ON p.id = pla.plan_id
WHERE 
    -- Flag plans with no inflows or inflows older than 365 days
    (
        pla.last_transaction_date IS NULL AND DATEDIFF(CURRENT_DATE, p.created_on) > 365
    )
    OR 
    (
        pla.last_transaction_date IS NOT NULL AND DATEDIFF(CURRENT_DATE, pla.last_transaction_date) > 365
    )
ORDER BY 
    inactivity_days DESC;  -- Sort with the most inactive accounts at the top
