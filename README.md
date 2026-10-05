# CBOT Corn & Soybean Futures — SQL Market Analysis

Daily futures price analysis on **8,404 trading days** of CBOT corn (`ZC=F`) and
soybean (`ZS=F`) continuous front-month contracts, **2010-01-04 → 2026-09-21**.
Built with SQLite + Python. Every query is a standalone `.sql` file you can run
and read.

## What it does

| Query | Question it answers | SQL techniques |
|---|---|---|
| `01_overview` | What's in the dataset? | `GROUP BY` aggregation |
| `02_largest_daily_moves` | Biggest single-day moves? | `LAG()` window, `ABS()` ranking |
| `03_monthly_avg_close` | Recent monthly trend? | Date truncation, filtered aggregation |
| `04_highest_volume_days` | When did volume explode? | `ROW_NUMBER()` partitioned ranking |
| `05_volatility_regimes` | Most turbulent 30-day stretches? | Rolling stdev via window frames, log returns |
| `06_soy_corn_ratio` | Soy/corn price ratio over time? | Conditional aggregation pivot (`CASE WHEN`) |
| `07_win_streaks` | Longest consecutive up-day runs? | Gaps-and-islands pattern |
| `08_annual_summary` | Year-by-year performance? | `ROW_NUMBER()` for first/last trading day |

## Key findings

- **Data-quality catch:** the largest "daily moves" (e.g. corn −23.6% on
  2013-07-15) are **contract-roll artifacts**, not market moves — the
  continuous series jumps from the expiring July contract to the next one.
  They cluster in mid-July (old-crop/new-crop switch). A production version
  would use a back-adjusted series.
- **Longest rallies:** soybeans ran 14 consecutive up-days (Aug–Sep 2020);
  corn ran 12 (Dec 2020).
- **2026 rally:** corn is +24.1% year-to-date through Sep 21, 2026, averaging
  ~153k contracts/day — well above its long-run average.
- **Soy/corn ratio** sat between 2.1 and 2.7 over the last two years (Sep 2026:
  2.51) — the range where acreage decisions get interesting.

## How to run it

```bash
python3 load_data.py          # fetch Yahoo Finance data -> data/futures.db
sqlite3 data/futures.db < queries/05_volatility_regimes.sql
```

Or open `data/futures.db` in any SQLite browser (DB Browser, VS Code extension)
and run the queries one by one.

## Data source

Yahoo Finance daily bars for `ZC=F` (CBOT Corn) and `ZS=F` (CBOT Soybeans),
pulled by `load_data.py`. Refresh anytime by re-running the script.

## Skills demonstrated

SQL (window functions, CTEs, gaps-and-islands, pivots) · Python (API ingestion,
data loading) · SQLite · futures market domain knowledge (contract rolls,
continuous series, soy/corn ratio)
