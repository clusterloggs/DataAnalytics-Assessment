-- Assessment_Q2.sql
-- Categorize customers by average transaction frequency per month:
-- High (≥10), Medium (3–9), Low (≤2)

WITH monthly_transactions AS (
    -- Step 1: Count how many transactions each customer makes per month
    SELECT 
        s.owner_id,  -- Customer ID
        DATE_FORMAT(s.transaction_date, '%Y-%m') AS month,  -- Extract year and month from the transaction date
        COUNT(*) AS transaction_count  -- Total number of transactions by the customer in that month
    FROM 
        savings_savingsaccount s
    WHERE 
        s.transaction_status = 'success'  -- Only include successful transactions
    GROUP BY 
        s.owner_id, DATE_FORMAT(s.transaction_date, '%Y-%m')  -- Group by customer and month
),

customer_avg AS (
    -- Step 2: Calculate the average number of transactions per month for each customer
    SELECT 
        owner_id,  -- Customer ID
        AVG(transaction_count) AS avg_transactions_per_month  -- Average monthly transactions per customer
    FROM 
        monthly_transactions
    GROUP BY 
        owner_id
)

-- Step 3: Categorize each customer by frequency and calculate the summary per category
SELECT 
    CASE 
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'  -- 10 or more transactions/month
        WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'  -- Between 3 and 9
        ELSE 'Low Frequency'  -- Less than 3
    END AS frequency_category,
    COUNT(*) AS customer_count,  -- Number of customers in each frequency category
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month  -- Average of averages for the category
FROM 
    customer_avg
GROUP BY 
    frequency_category  -- Group results by the defined frequency category
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;  -- Ensure consistent output order: High > Medium > Low