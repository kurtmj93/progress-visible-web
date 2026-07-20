#!/usr/bin/env bash
#
# Deploy the built site to S3 + CloudFront.
#
#   1. Build fresh into dist/
#   2. Sync hashed assets with a long, immutable cache (Astro fingerprints them)
#   3. Sync HTML with no-cache so page changes appear immediately
#   4. Invalidate CloudFront so the edge serves the new files now
#
# Requires: awscli v2, a .env with PV_S3_BUCKET + PV_CLOUDFRONT_DISTRIBUTION_ID.
# This mirrors the pipeline planned for discbound.app — treat it as the rehearsal.

set -euo pipefail

# --- Load config -------------------------------------------------------------
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  set -a; source .env; set +a
fi

: "${PV_S3_BUCKET:?Set PV_S3_BUCKET (see .env.example)}"
: "${PV_CLOUDFRONT_DISTRIBUTION_ID:?Set PV_CLOUDFRONT_DISTRIBUTION_ID (see .env.example)}"

echo "▸ Building…"
npm run build

echo "▸ Uploading fingerprinted assets (immutable, 1y cache)…"
# Everything Astro fingerprints lives under /_astro/. Safe to cache hard.
aws s3 sync dist/ "s3://${PV_S3_BUCKET}" \
  --delete \
  --exclude "*.html" \
  --cache-control "public, max-age=31536000, immutable"

echo "▸ Uploading HTML (no-cache so pages update immediately)…"
aws s3 sync dist/ "s3://${PV_S3_BUCKET}" \
  --exclude "*" \
  --include "*.html" \
  --cache-control "public, max-age=0, must-revalidate" \
  --content-type "text/html; charset=utf-8"

echo "▸ Invalidating CloudFront…"
aws cloudfront create-invalidation \
  --distribution-id "${PV_CLOUDFRONT_DISTRIBUTION_ID}" \
  --paths "/*" \
  --query 'Invalidation.Id' --output text

echo "✓ Deployed to https://${PV_S3_BUCKET%%.s3*} — allow a minute for the edge to refresh."
