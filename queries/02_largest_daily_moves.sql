-- 02_largest_daily_moves.sql — top 10 biggest single-day % moves per contract
-- (the days a risk desk cares about most)
--
-- DATA NOTE: ZC=F / ZS=F are *continuous front-month* series. The biggest
-- "moves" (e.g. corn -23.6% on 2013-07-15) are contract-roll artifacts —
-- the series jumping from the expiring July contract to the next one —
-- not real single-day market moves. A production version would use a
-- back-adjusted continuous series or single-contract data. The roll dates
-- clustering in mid-July (old-crop/new-crop switch) is the giveaway.
WITH moves AS (
    SELECT
        symbol,
        date,
        close,
        LAG(close) OVER (PARTITION BY symbol ORDER BY date) AS prev_close
    FROM daily_prices
)
SELECT
    symbol,
    date,
    ROUND(prev_close, 2)                        AS prev_close,
    ROUND(close, 2)                             AS close,
    ROUND(100.0 * (close - prev_close) / prev_close, 2) AS pct_move
FROM moves
WHERE prev_close IS NOT NULL
ORDER BY ABS(100.0 * (close - prev_close) / prev_close) DESC
LIMIT 20;
