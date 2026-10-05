-- 05_volatility_regimes.sql — 30-day rolling volatility of daily returns.
-- Finds the most turbulent month-long stretches (risk regimes).
WITH rets AS (
    SELECT
        symbol,
        date,
        LN(close / LAG(close) OVER (PARTITION BY symbol ORDER BY date)) AS log_ret
    FROM daily_prices
),
vol AS (
    SELECT
        symbol,
        date,
        -- sample stdev of log returns over trailing 30 trading days, annualized
        SQRT(252) * SQRT(
            (SUM(log_ret * log_ret) OVER w - SUM(log_ret) OVER w * SUM(log_ret) OVER w / 30) / 29
        ) AS ann_vol
    FROM rets
    WHERE log_ret IS NOT NULL
    WINDOW w AS (PARTITION BY symbol ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
)
SELECT symbol, date AS window_end, ROUND(ann_vol * 100, 1) AS annualized_vol_pct
FROM vol
WHERE ann_vol IS NOT NULL
ORDER BY ann_vol DESC
LIMIT 20;
