#!/usr/bin/env bash
# Publish a parquet export to Source Cooperative.
#
# Version tags encode the snapshot date of the dump (v26.06 = June 2026).  The
# two servers can carry different tags when their dumps arrive at different
# times; `available_releases()` lists each server independently.
#
# Requires an `rclone` remote named `source` holding Source Cooperative creds.
#
# Usage:  bash data-raw/upload.sh <workdir> <fb-version> <slb-version>
#   e.g.  bash data-raw/upload.sh /tmp/fishbase-import 26.06 26.06
set -euo pipefail

W="${1:?workdir}"; FB="${2:?fb version, e.g. 26.06}"; SLB="${3:?slb version, e.g. 26.06}"
DEST="source:us-west-2.opendata.source.coop/cboettig/fishbase"

# --s3-no-check-bucket: the publishing credentials can write the prefix but are
# not granted s3:CreateBucket, which rclone otherwise probes for.
for pair in "fb/v$FB=$W/out/fb/parquet" "slb/v$SLB=$W/out/slb/parquet"; do
  prefix="${pair%%=*}"; dir="${pair#*=}"
  rclone copy --s3-no-check-bucket --transfers 8 --checksum --stats 60s \
    "$dir" "$DEST/$prefix/parquet"
  rclone check --s3-no-check-bucket --checksum "$dir" "$DEST/$prefix/parquet"
done

echo "Published.  Confirm the package sees them with:"
echo "  Rscript -e 'devtools::load_all(\".\"); available_releases(); nrow(fb_tbl(\"species\"))'"
