# Preparing a new data release

FishBase and SeaLifeBase send `fbapp.7z` / `slbapp.7z` (7z-compressed
`mysqldump` output) roughly annually.  Publishing them is two commands:

```bash
# 1. drop the dumps in imports/ (git-ignored, excluded from the build), then
bash data-raw/import_dumps.sh /tmp/fishbase-import
# 2. read the verification summary, then publish (args are fb and slb versions)
bash data-raw/upload.sh /tmp/fishbase-import 26.07 26.04
```

`import_dumps.sh` unpacks the dumps into a throwaway local MariaDB instance and
calls `export_parquet.py`, which writes one zstd-compressed parquet file per
table via DuckDB's `mysql` extension, then `verify_export.py`, which checks the
result and exits non-zero if anything looks wrong.  `upload.sh` publishes to
Source Cooperative under `cboettig/fishbase/{fb,slb}/v<version>/parquet/`,
which is what `fb_urls()` lists.

Nothing in the R package needs to change to ship a release:
`available_releases()` reads the bucket and `version = "latest"` picks the
highest version present.

Version tags encode the *snapshot date* of the dump (`v26.07` = July 2026).
The two servers can carry different tags when their dumps arrive at different
times, since releases are listed per server.

Requires `p7zip-full`, `mariadb-server` (10.11+), `python3` with `duckdb`, and
an `rclone` remote named `source` holding Source Cooperative credentials.
Budget roughly 10 GB of scratch disk and an hour of wall clock.

## What the verification covers

`verify_export.py` compares every table's parquet row count against the source
database, diffs the table list against the most recent release already on
Source Cooperative, and checks that the two servers did not get crossed.  Run
it *before* uploading: it compares against whatever release is currently
newest, so once you publish, the comparison baseline becomes the new release.

## Notes and gotchas

- The two dumps come from different MySQL versions (5.6 for `fbapp`, 8.0 for
  `slbapp`).  MariaDB rejects MySQL 8's `utf8mb4_0900_ai_ci` collation, so the
  import rewrites it; only the data matters here, not collation semantics.
- DuckDB's `mysql` ATTACH exposes *every* schema on the server, not just the
  one named in the connection string.  `export_parquet.py` therefore filters on
  `schema_name` and fully qualifies each table — an unqualified `src."species"`
  silently resolves across databases and will mix FishBase and SeaLifeBase.
  `verify_export.py` guards against a regression here.
- The publishing credentials can write the prefix but are not granted
  `s3:CreateBucket`, which `rclone` probes for unless given
  `--s3-no-check-bucket`.
- Recent dumps have included working tables from the FishBase team (`*_copy`,
  `mp_withphotos`, `country.orig`).  They are published as-is, since these are
  raw snapshots of the backend, but they show up in the verification diff as
  new tables — worth a glance before publishing.
