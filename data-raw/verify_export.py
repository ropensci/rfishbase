#!/usr/bin/env python3
"""Sanity-check a parquet export before publishing it.

Confirms every table's parquet row count matches the source database, and diffs
the table list against the most recent release already on Source Cooperative.

Usage: verify_export.py <workdir> [mysql_port]
"""
import glob
import os
import sys
import urllib.request
import xml.etree.ElementTree as ET

import duckdb

BUCKET = "us-west-2.opendata.source.coop"
NS = "{http://s3.amazonaws.com/doc/2006-03-01/}"


def published_tables(sv, version):
    url = (
        f"https://s3.{BUCKET.split('.')[0]}.amazonaws.com/{BUCKET}"
        f"?list-type=2&prefix=cboettig/fishbase/{sv}/{version}/parquet/&max-keys=1000"
    )
    root = ET.fromstring(urllib.request.urlopen(url).read())
    keys = [c.find(f"{NS}Key").text for c in root.findall(f"{NS}Contents")]
    return {os.path.basename(k)[: -len(".parquet")] for k in keys if k.endswith(".parquet")}


def latest_version(sv):
    url = (
        f"https://s3.{BUCKET.split('.')[0]}.amazonaws.com/{BUCKET}"
        f"?list-type=2&prefix=cboettig/fishbase/{sv}/&delimiter=/"
    )
    root = ET.fromstring(urllib.request.urlopen(url).read())
    prefixes = [p.find(f"{NS}Prefix").text.rstrip("/").split("/")[-1]
                for p in root.findall(f"{NS}CommonPrefixes")]
    return max(p for p in prefixes if p.startswith("v"))


def main(W, port):
    con = duckdb.connect()
    con.execute("INSTALL mysql; LOAD mysql;")
    con.execute(
        f"ATTACH 'host=127.0.0.1 port={port} user=root database=fbapp' AS src (TYPE mysql, READ_ONLY)"
    )

    problems = []
    for db, sv in [("fbapp", "fb"), ("slbapp", "slb")]:
        d = f"{W}/out/{sv}/parquet"
        tables = [
            r[0]
            for r in con.execute(
                "SELECT table_name FROM duckdb_tables() "
                "WHERE database_name='src' AND schema_name=? ORDER BY 1",
                [db],
            ).fetchall()
        ]

        mismatched = []
        for t in tables:
            want = con.execute(f'SELECT count(*) FROM src."{db}"."{t}"').fetchone()[0]
            got = con.execute(f"SELECT count(*) FROM read_parquet('{d}/{t}.parquet')").fetchone()[0]
            if want != got:
                mismatched.append((t, want, got))

        exported = {os.path.basename(f)[: -len(".parquet")] for f in glob.glob(f"{d}/*.parquet")}
        prev_version = latest_version(sv)
        prev = published_tables(sv, prev_version)
        size = sum(os.path.getsize(f) for f in glob.glob(f"{d}/*.parquet"))

        print(f"== {sv}: {len(exported)} tables, {size / 1e6:.0f} MB")
        print(f"   row-count mismatches vs source db: {mismatched or 'none'}")
        print(f"   new tables vs {prev_version}: {sorted(exported - prev) or 'none'}")
        print(f"   tables missing vs {prev_version}: {sorted(prev - exported) or 'none'}")

        if mismatched:
            problems.append(f"{sv}: {len(mismatched)} row-count mismatches")
        if prev - exported:
            problems.append(f"{sv}: {len(prev - exported)} tables dropped since {prev_version}")
        if len(exported) != len(tables):
            problems.append(f"{sv}: exported {len(exported)} files for {len(tables)} tables")

    # A table that exists in both schemas must not be exported twice: duckdb's mysql
    # ATTACH exposes every schema on the server, so an unqualified table reference
    # silently mixes the two databases.
    fb_sp = con.execute(f"SELECT count(*) FROM read_parquet('{W}/out/fb/parquet/species.parquet')").fetchone()[0]
    slb_sp = con.execute(f"SELECT count(*) FROM read_parquet('{W}/out/slb/parquet/species.parquet')").fetchone()[0]
    if fb_sp == slb_sp:
        problems.append("fb and slb species tables have identical row counts - schemas may be crossed")
    print(f"== species rows: fb {fb_sp}, slb {slb_sp}")

    if problems:
        print("\nFAILED:")
        for p in problems:
            print(f"  - {p}")
        sys.exit(1)
    print("\nAll checks passed.")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else "3307")
