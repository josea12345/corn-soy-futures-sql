-- 07_win_streaks.sql — longest consecutive up-day streaks per contract
-- (gaps-and-islands: a streak breaks whenever the day isn't an up day)
WITH flagged AS (
    SELECT
        symbol,
        date,
        CASE WHEN close > LAG(close) OVER (PARTITION BY symbol ORDER BY date)
             THEN 1 ELSE 0 END AS is_up
    FROM daily_prices
),
grouped AS (
    SELECT
        symbol,
        date,
        is_up,
        ROW_NUMBER() OVER (PARTITION BY symbol ORDER BY date)
          - ROW_NUMBER() OVER (PARTITION BY symbol, is_up ORDER BY date) AS grp
    FROM flagged
)
SELECT
    symbol,
    MIN(date) AS streak_start,
    MAX(date) AS streak_end,
    COUNT(*)  AS up_days_in_a_row
FROM grouped
WHERE is_up = 1
GROUP BY symbol, grp
ORDER BY up_days_in_a_row DESC
LIMIT 10;
