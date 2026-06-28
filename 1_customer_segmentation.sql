WITH customer_ltv AS (
    SELECT
        customerkey,
        cleaned_name,
        ROUND(SUM(total_net_revenue)::NUMERIC, 2) AS total_ltv
    FROM cohort_analysis
    GROUP BY
        customerkey,
        cleaned_name
), customer_segments AS (
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
FROM customer_ltv
), segment_values AS (
    SELECT
        c.*,
        CASE
            WHEN c.total_ltv < cs.ltv_25th_percentile THEN '1 - Low_Value'
            WHEN c.total_ltv BETWEEN cs.ltv_25th_percentile AND cs.ltv_75th_percentile THEN '2 - Mid_Value'
            WHEN c.total_ltv > cs.ltv_75th_percentile THEN '3 - High_Value'
        END AS customer_segment
    FROM customer_ltv AS c, customer_segments AS cs
)
SELECT
    customer_segment,
    SUM(total_ltv) AS total_ltv,
    COUNT(DISTINCT customerkey) AS customer_count,
    ROUND(SUM(total_ltv) / COUNT(DISTINCT customerkey), 2) AS avg_ltv
FROM segment_values
GROUP BY customer_segment
ORDER BY customer_segment