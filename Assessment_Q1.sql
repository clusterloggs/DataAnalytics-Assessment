-- Assessment_Q1.sql

-- Select customers who have both savings and investment plans,
-- and calculate the total value of their confirmed deposits.

SELECT 
    u.id AS owner_id,  -- Unique ID of the customer
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full name of the customer
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,  -- Count of unique savings plans
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,  -- Count of unique investment plans
    SUM(s.confirmed_amount) / 100 AS total_deposits  -- Total confirmed deposits (converted from kobo to currency)
FROM 
    users_customuser u  -- Customer table
JOIN 
    plans_plan p ON u.id = p.owner_id  -- Join to plans created by the user
JOIN 
    savings_savingsaccount s ON p.id = s.plan_id  -- Join to savings transactions under each plan
WHERE 
    p.is_deleted = 0  -- Include only active (not deleted) plans
    AND p.is_archived = 0  -- Exclude archived plans
    AND s.confirmed_amount > 0  -- Consider only positive inflow transactions
GROUP BY 
    u.id, u.first_name, u.last_name  -- Group by unique customer for aggregation
HAVING 
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) > 0  -- Ensure the customer has at least one savings plan
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) > 0  -- Ensure the customer has at least one investment plan
ORDER BY 
    total_deposits DESC;  -- Sort by total deposits in descending order to highlight high-value customers