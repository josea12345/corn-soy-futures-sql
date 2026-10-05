-- 04_highest_volume_days.sql — top 10 volume days per contract
-- (volume spikes usually mean news, reports, or limit moves)
SELECT symbol, date, ROUND(close, 2) AS close, volume
FROM (
    SELECT
        symbol, date, close, volume,
        ROW_NUMBER() OVER (PARTITION BY symbol ORDER BY volume DESC) AS rn
    FROM daily_prices
    WHERE volume > 0
)
WHERE rn <= 10
ORDER BY symbol, volume DESC;
