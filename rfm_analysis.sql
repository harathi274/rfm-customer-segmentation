-- Create and use database
CREATE DATABASE IF NOT EXISTS rfm_project;
USE rfm_project;

-- Create table
CREATE TABLE IF NOT EXISTS orders (
    customer_id INT,
    order_id INT,
    order_date DATE,
    amount DECIMAL(10,2)
);

-- Insert data
INSERT INTO orders VALUES
(1, 101, '2024-01-01', 500),
(1, 102, '2024-02-01', 300),
(2, 103, '2024-01-10', 200),
(2, 104, '2024-03-01', 100),
(3, 105, '2024-03-05', 700),
(4, 106, '2024-01-15', 150),
(4, 107, '2024-01-20', 150),
(5, 108, '2024-02-10', 400);

-- Final RFM Query
WITH rfm AS (
    SELECT 
        customer_id,
        DATEDIFF('2024-03-10', MAX(order_date)) AS recency,
        COUNT(order_id) AS frequency,
        SUM(amount) AS monetary
    FROM orders
    GROUP BY customer_id
),
scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm
)

SELECT *,
    -- Customer Segment
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN f_score >= 4 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score <= 2 THEN 'At Risk'
        ELSE 'Regular Customers'
    END AS customer_segment,

    -- Churn Risk (Prediction feel)
    CASE 
        WHEN recency > 30 THEN 'High Churn Risk'
        WHEN recency BETWEEN 15 AND 30 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS churn_risk,

    -- Business Recommendation
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Give loyalty rewards'
        WHEN r_score <= 2 THEN 'Send discounts / re-engage'
        ELSE 'Promote regular offers'
    END AS recommendation

FROM scores;