-- Assessment_Q1.sql
WITH savings_owners AS (
    SELECT p.owner_id, COUNT(DISTINCT p.id) AS savings_count
    FROM plans_plan p
    JOIN savings_savingsaccount s ON p.id = s.plan_id
    WHERE p.is_regular_savings = 1 AND s.confirmed_amount > 0
    GROUP BY p.owner_id
),
investment_owners AS (
    SELECT p.owner_id, COUNT(DISTINCT p.id) AS investment_count
    FROM plans_plan p
    JOIN savings_savingsaccount s ON p.id = s.plan_id
    WHERE p.is_a_fund = 1 AND s.confirmed_amount > 0
    GROUP BY p.owner_id
),
total_deposits AS (
    SELECT owner_id, SUM(confirmed_amount) / 100.0 AS total_deposits
    FROM savings_savingsaccount
    GROUP BY owner_id
)
SELECT 
    u.id AS owner_id,
    u.name,
    COALESCE(s.savings_count, 0) AS savings_count,
    COALESCE(i.investment_count, 0) AS investment_count,
    td.total_deposits
FROM users_customuser u
JOIN savings_owners s ON u.id = s.owner_id
JOIN investment_owners i ON u.id = i.owner_id
JOIN total_deposits td ON u.id = td.owner_id
ORDER BY td.total_deposits DESC;

-- Assessment_Q2.sql
WITH customer_avg AS (
    SELECT 
        owner_id AS customer_id,
        COUNT(*) AS total_transactions,
        TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1 AS num_months,
        COUNT(*) / (TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1) AS avg_transactions
    FROM savings_savingsaccount
    GROUP BY owner_id
),
categories AS (
    SELECT 
        customer_id,
        CASE 
            WHEN avg_transactions >= 10 THEN 'High Frequency'
            WHEN avg_transactions >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_transactions
    FROM customer_avg
)
SELECT 
    frequency_category,
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(avg_transactions), 1) AS avg_transactions_per_month
FROM categories
GROUP BY frequency_category
ORDER BY frequency_category;

-- Assessment_Q3.sql
SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    COALESCE(MAX(s.created_on), p.created_on) AS last_transaction_date,
    DATEDIFF(CURDATE(), COALESCE(MAX(s.created_on), p.created_on)) AS inactivity_days
FROM plans_plan p
LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id AND s.confirmed_amount > 0
WHERE 
    p.is_archived = 0 
    AND p.is_deleted = 0
    AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)
GROUP BY p.id, p.owner_id, type
HAVING inactivity_days > 365;

-- Assessment_Q4.sql
SELECT
    u.id AS customer_id,
    u.name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    ROUND((COALESCE(SUM(s.confirmed_amount), 0) * 0.00001 * 12) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1), 2) AS estimated_clv
FROM users_customuser u
LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
GROUP BY u.id, u.name
HAVING tenure_months > 0
ORDER BY estimated_clv DESC;