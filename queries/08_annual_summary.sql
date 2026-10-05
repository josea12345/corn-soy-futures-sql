-- 08_annual_summary.sql — yearly OHLC + volume summary per contract
WITH ranked AS (
    SELECT
        symbol,
        SUBSTR(date, 1, 4) AS year,
        low, high, close, volume,
        ROW_NUMBER() OVER (PARTITION BY symbol, SUBSTR(date, 1, 4) ORDER BY date)      AS rn_first,
        ROW_NUMBER() OVER (PARTITION BY symbol, SUBSTR(date, 1, 4) ORDER BY date DESC)  AS rn_last
    FROM daily_prices
)
SELECT
    symbol,
    year,
    ROUND(MIN(low), 2)   AS year_low,
    ROUND(MAX(high), 2)  AS year_high,
    ROUND(AVG(close), 2) AS avg_close,
    ROUND(
        100.0 * (MAX(CASE WHEN rn_last = 1 THEN close END)
               - MAX(CASE WHEN rn_first = 1 THEN close END))
        / MAX(CASE WHEN rn_first = 1 THEN close END), 1
    )                    AS year_pct_change,
    ROUND(AVG(volume))   AS avg_daily_volume
FROM ranked
GROUP BY symbol, year
ORDER BY symbol, year;
