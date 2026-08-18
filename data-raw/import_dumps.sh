#!/usr/bin/env bash
# Import FishBase / SeaLifeBase MySQL dumps and export them as parquet.
#
# The FishBase team sends `fbapp.7z` / `slbapp.7z` (7z-compressed mysqldump)
# roughly annually.  Drop them in `imports/` (git- and build-ignored), run this
# script, sanity-check the result, then publish with `upload.sh`.
#
# Requires: p7zip-full, mariadb-server (10.11+), python3 with duckdb.
# Budget ~10 GB of scratch disk and about an hour of wall clock.
#
# Usage:  bash data-raw/import_dumps.sh [workdir]
set -euo pipefail

W="${1:-/tmp/fishbase-import}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT=3307

for f in fbapp slbapp; do
  [ -f "$REPO/imports/$f.7z" ] || { echo "missing $REPO/imports/$f.7z" >&2; exit 1; }
done

mkdir -p "$W"/{sql,mysql-data,tmp,out/fb/parquet,out/slb/parquet}

7z x -o"$W/sql" -y "$REPO/imports/fbapp.7z"
7z x -o"$W/sql" -y "$REPO/imports/slbapp.7z"

mariadb-install-db --datadir="$W/mysql-data" --user="$(whoami)" \
  --auth-root-authentication-method=normal --skip-test-db

cat > "$W/my.cnf" <<CNF
[mysqld]
user                = $(whoami)
bind-address        = 127.0.0.1
port                = $PORT
socket              = $W/mysqld.sock
pid-file            = $W/mysqld.pid
datadir             = $W/mysql-data
tmpdir              = $W/tmp
key_buffer_size     = 8G
myisam_sort_buffer_size = 4G
innodb_buffer_pool_size = 16G
innodb_flush_log_at_trx_commit = 0
innodb_doublewrite  = 0
max_allowed_packet  = 1G
skip-log-bin
sql_mode            = NO_ENGINE_SUBSTITUTION
CNF

mariadbd --defaults-file="$W/my.cnf" > "$W/mysqld.log" 2>&1 &
for _ in $(seq 1 60); do
  mariadb-admin --socket="$W/mysqld.sock" -u root ping >/dev/null 2>&1 && break
  sleep 2
done
mariadb-admin --socket="$W/mysqld.sock" -u root ping >/dev/null \
  || { echo "server failed to start, see $W/mysqld.log" >&2; exit 1; }

# The fbapp dump comes from MySQL 5.6, slbapp from MySQL 8.0.  MariaDB does not
# know MySQL 8's default collation, so rewrite it on the way in; only the data
# matters here, not the collation semantics.
mariadb --socket="$W/mysqld.sock" -u root < "$W/sql/fbapp.sql"
sed 's/utf8mb4_0900_ai_ci/utf8mb4_general_ci/g' "$W/sql/slbapp.sql" \
  | mariadb --socket="$W/mysqld.sock" -u root

python3 "$REPO/data-raw/export_parquet.py" fbapp  "$W/out/fb/parquet"
python3 "$REPO/data-raw/export_parquet.py" slbapp "$W/out/slb/parquet"

python3 "$REPO/data-raw/verify_export.py" "$W" "$PORT"

mariadb-admin --socket="$W/mysqld.sock" -u root shutdown
echo "Export complete: $W/out.  Publish with data-raw/upload.sh"
