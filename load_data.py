"""Load Yahoo Finance daily futures data (ZC=F corn, ZS=F soybeans) into SQLite."""
import json
import sqlite3
from datetime import datetime, timezone

DB = "data/futures.db"
FILES = {
    "ZC": "data/zc_yahoo.json",   # CBOT Corn continuous front-month
    "ZS": "data/zs_yahoo.json",   # CBOT Soybean continuous front-month
}

conn = sqlite3.connect(DB)
cur = conn.cursor()
cur.execute("DROP TABLE IF EXISTS daily_prices")
cur.execute(
    """
    CREATE TABLE daily_prices (
        symbol TEXT NOT NULL,        -- 'ZC' corn, 'ZS' soybeans
        date   TEXT NOT NULL,        -- YYYY-MM-DD
        open   REAL,
        high   REAL,
        low    REAL,
        close  REAL,
        volume INTEGER,
        PRIMARY KEY (symbol, date)
    )
    """
)

total = 0
for symbol, path in FILES.items():
    with open(path) as f:
        payload = json.load(f)
    result = payload["chart"]["result"][0]
    stamps = result["timestamp"]
    quote = result["indicators"]["quote"][0]
    rows = 0
    for i, ts in enumerate(stamps):
        o, h, l, c = (quote[k][i] for k in ("open", "high", "low", "close"))
        if c is None:  # skip days with no quote (holidays/halts)
            continue
        v = quote["volume"][i]
        cur.execute(
            "INSERT OR REPLACE INTO daily_prices VALUES (?,?,?,?,?,?,?)",
            (
                symbol,
                datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y-%m-%d"),
                o, h, l, c,
                int(v) if v else 0,
            ),
        )
        rows += 1
    total += rows
    print(f"{symbol}: {rows} trading days loaded")

conn.commit()

# sanity check
for row in cur.execute(
    "SELECT symbol, COUNT(*), MIN(date), MAX(date) FROM daily_prices GROUP BY symbol"
):
    print(row)
conn.close()
print(f"done — {total} rows in {DB}")
