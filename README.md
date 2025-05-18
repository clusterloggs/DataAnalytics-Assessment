# DataAnalytics-Assessment

## Overview
This repository contains my structured SQL solutions for a multi-table Data Analytics assessment,
designed to evaluate data retrival, aggregation, and business logic interpretation using MySQL.

## Solutions

### Question 1: High-Value Customers with Multiple Products
**Objective**: Identify customers with both savings and investment plans.  
**Approach**:
- Joined user data with plan and transaction tables
- Used conditional aggregation to count different product types
- Filtered for active accounts with confirmed deposits
- Converted amounts from kobo to currency
- Sorted by total deposits to highlight high-value customers

**Key Techniques**:
- CASE statements for product type classification
- HAVING clause for multi-product requirement
- SUM aggregation with currency conversion

### Question 2: Transaction Frequency Analysis
**Objective**: Categorize customers by transaction frequency.  
**Approach**:
- Calculated monthly transaction counts per customer
- Computed customer averages across months
- Applied business rules for frequency segmentation
- Aggregated results by frequency category

**Key Techniques**:
- CTEs for modular calculation
- DATE_FORMAT for time period grouping
- Conditional categorization with CASE
- ROUND for presentable metrics

### Question 3: Account Inactivity Alert
**Objective**: Flag accounts with no transactions transactions for >1 year.  
**Approach**:
- Identified last successful transactions date per account
- Calculated days since last activity
- Included accounts with no transactions (using creation date)
- Filtered for 365+ days inactivity
- Clearly labeled account types

**Key Techniques**:
- LEFT JOIN with NULL handling
- DATEDIFF for inactivity calculation
- COALESCE for missing transaction dates
- Explicit account type classification

### Question 4: Customer Lifetime Value (CLV) Estimation  
**Objective**: Estimate customer value based on transaction patterns.  
**Approach**:
- Calculated account tenure in months
- Counted successful transactions
- Applied CLV formula: (transactions/tenure) × 12 × (0.1% of total amount)
- Handled edge cases (new customers, null values)
- Presented results ordered by estimated value

**Key Techniques**:
- TIMESTAMPDIFF for tenure calculation
- COALESCE for null handling
- Business metric calculation with proper unit conversion
- ROUND for clean financial reporting

## Challenges & Solutions

1. **Data Understanding**:
   - Complex schema with many fields → Focused on key tables/columns per question
   - Kobo currency units → Consistent /100 conversion in all queries

2. **Edge Cases**:
   - New customers in CLV calculation → Added tenure filters
   - Accounts with no transactions → Used COALESCE with creation dates

3. **Performance**:
   - Large transaction history → Used efficient joins and aggregations
   - Multiple calculations → Structured with CTEs for readability

4. **Business Logic**:
   - Clarified "active" accounts → Used is_deleted/is_archived flags
   - Defined transactions → Confirmed_amount > 0 filter

## Usage

1. Repository Structure:
```
DataAnalytics-Assessment/ 
│
├── Assessment_Q1.sql    # High-Value Customers with Multiple Products
├── Assessment_Q2.sql    # Transaction Frequency Analysis
├── Assessment_Q3.sql    # Account Inactivity Alert
├── Assessment_Q4.sql    # Customer Lifetime Value Estimation
└── README.md            # Project overview and explanations
```

2. Requirements:
- MySQL-compatible database
- Tables: 
      * users_customuser,savings_savingsaccount, plans_plan, withdrawals_withdrawal

3. How to Run

1. Load the assessment tables (`users_customuser`, `savings_savingsaccount`, `plans_plan`, and `withdrawals_withdrawal`) into a MySQL-compatible database.
2. Open each SQL file (`Assessment_Q1.sql` to `Assessment_Q4.sql`) in a MySQL client or editor.
3. Run them individually to view the results.
4. Ensure `transaction_status = 'success'` and `confirmed_amount > 0` filters are active for accurate results.


## Notes

- All monetary values converted from kobo (÷100)
- Only successful transactions considered (transaction_status = 'success')
- Active accounts filtered (is_deleted = 0 AND is_archived = 0)
- Solutions optimized for both accuracy and performance