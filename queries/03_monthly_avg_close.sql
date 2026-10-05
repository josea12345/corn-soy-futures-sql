-- 03_monthly_avg_close.sql — monthly average settlement, most recent 12 months
SELECT
    symbol,
    SUBSTR(date, 1, 7)       AS month,
    ROUND(AVG(close), 2)     AS avg_close,
    ROUND(MIN(low), 2)       AS month_low,
    ROUND(MAX(high), 2)      AS month_high,
    COUNT(*)                 AS trading_days
FROM daily_prices
WHERE date >= date((SELECT MAX(date) FROM daily_prices), '-12 months')
GROUP BY symbol, month
ORDER BY symbol, month;
