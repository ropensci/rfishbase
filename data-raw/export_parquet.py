#!/usr/bin/env python3
"""Export one MySQL schema of a fishbase snapshot to per-table parquet files.

Usage: export_parquet.py <mysql_schema> <outdir>
"""
import json
import sys

import duckdb

db, outdir = sys.argv[1], sys.argv[2]

con = duckdb.connect()
con.execute("INSTALL mysql; LOAD mysql;")
con.execute(
    f"ATTACH 'host=127.0.0.1 port=3307 user=root database={db}' AS src (TYPE mysql, READ_ONLY)"
)

# NB: the mysql attach exposes every schema on the server, so scope explicitly
tables = [
    r[0]
    for r in con.execute(
        "SELECT table_name FROM duckdb_tables() "
        "WHERE database_name='src' AND schema_name=? ORDER BY table_name",
        [db],
    ).fetchall()
]
print(f"{db}: {len(tables)} tables", flush=True)

ok, failed = [], {}
for i, tbl in enumerate(tables, 1):
    dest = f"{outdir}/{tbl}.parquet"
    try:
        con.execute(
            f'COPY (SELECT * FROM src."{db}"."{tbl}") TO \'{dest}\' '
            "(FORMAT parquet, COMPRESSION zstd)"
        )
        n = con.execute(f"SELECT count(*) FROM read_parquet('{dest}')").fetchone()[0]
        ok.append((tbl, n))
        print(f"[{i}/{len(tables)}] {tbl}: {n}", flush=True)
    except Exception as e:
        failed[tbl] = str(e).split("\n")[0]
        print(f"[{i}/{len(tables)}] {tbl}: FAILED {failed[tbl]}", flush=True)

with open(f"{outdir}/../{db}_export_report.json", "w") as f:
    json.dump({"ok": ok, "failed": failed}, f, indent=2)

print(f"done: {len(ok)} ok, {len(failed)} failed", flush=True)
