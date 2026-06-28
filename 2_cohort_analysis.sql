SELECT
        cohort_year,
        ROUND(SUM(total_net_revenue) :: NUMERIC, 2) AS total_revenue,
        COUNT(DISTINCT customerkey) AS total_customers,
        ROUND((SUM(total_net_revenue) / COUNT(DISTINCT customerkey)) :: NUMERIC, 2) AS customer_revenue
FROM cohort_analysis
WHERE orderdate = first_purchase_date
GROUP BY cohort_year
ORDER BY cohort_year