-- 01_overview.sql — dataset shape: coverage per contract
SELECT
    symbol,
    COUNT(*)            AS trading_days,
    MIN(date)           AS first_date,
    MAX(date)           AS last_date,
    ROUND(AVG(volume))  AS avg_daily_volume
FROM daily_prices
GROUP BY symbol;
