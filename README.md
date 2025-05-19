# DataAnalytics-Assessment

## Approach and Explanations

### Question 1: High-Value Customers with Multiple Products
**Objective:** Identify customers with both funded savings and investment plans.  
**Approach:**  
1. **CTEs for Savings and Investment Plans:** Separate queries to count funded plans per customer.  
2. **Total Deposits:** Sum all confirmed deposits for each customer.  
3. **Join Results:** Combine CTEs and total deposits, filtering customers present in both CTEs.  

**Challenges:** Ensuring correct aggregation and handling customers without either plan type using `COALESCE`.

### Question 2: Transaction Frequency Analysis
**Objective:** Categorize customers by transaction frequency.  
**Approach:**  
1. **Calculate Average Transactions:** Compute monthly average using transaction date range.  
2. **Categorization:** Use `CASE` to assign frequency categories.  
3. **Aggregate Results:** Group by category to count customers and compute averages.  

**Challenges:** Avoiding integer division by casting to float and handling edge cases like single transactions.

### Question 3: Account Inactivity Alert
**Objective:** Flag accounts with no inflow for over a year.  
**Approach:**  
1. **Identify Active Plans:** Filter non-archived/deleted plans.  
2. **Track Last Inflow:** Use `LEFT JOIN` to include plans without transactions.  
3. **Inactivity Check:** Compare last transaction/creation date to current date.  

**Challenges:** Handling plans with no transactions by using `COALESCE` on plan creation dates.

### Question 4: Customer Lifetime Value (CLV) Estimation
**Objective:** Estimate CLV based on tenure and transactions.  
**Approach:**  
1. **Tenure Calculation:** Months since user signup.  
2. **Profit Calculation:** Sum confirmed deposits, convert to profit (0.1%).  
3. **CLV Formula:** Apply given formula with safeguards against division by zero.  

**Challenges:** Correctly converting kobo to base currency and handling users with no transactions.
