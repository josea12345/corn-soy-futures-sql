-- 06_soy_corn_ratio.sql — monthly soybean/corn price ratio.
-- A classic ag-economics gauge: high ratios push acreage toward soybeans.
WITH monthly AS (
    SELECT
        SUBSTR(date, 1, 7) AS month,
        AVG(CASE WHEN symbol = 'ZS' THEN close END) AS soy_avg,
        AVG(CASE WHEN symbol = 'ZC' THEN close END) AS corn_avg
    FROM daily_prices
    GROUP BY month
)
SELECT
    month,
    ROUND(soy_avg, 2)  AS soy_avg_close,
    ROUND(corn_avg, 2) AS corn_avg_close,
    ROUND(soy_avg / corn_avg, 2) AS soy_corn_ratio
FROM monthly
ORDER BY month DESC
LIMIT 24;
