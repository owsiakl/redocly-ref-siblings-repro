#!/usr/bin/env bash
# Usage: ./run.sh [redocly-cli-version] [redocly-framework-version]   (default: latest for both)
set -euo pipefail
cd "$(dirname "$0")"

rm -rf out
CLI=(npx --yes "@redocly/cli@${1:-latest}")
"${CLI[@]}" generate-client repro --config ./redocly.yaml

echo
echo '--- Generated ItemCreate type ---'
echo "@redocly/cli $("${CLI[@]}" --version 2>/dev/null)"
sed -n '/^export type ItemCreate /,/^};/p' out/client.ts

echo
echo '--- Generated ItemCreate zod schema ---'
sed -n '/^export const ItemCreateSchema/,/^});/p' out/client.zod.ts

echo
echo '--- API docs page of POST /items ---'
REALM=(npx --yes --package "@redocly/framework@${2:-latest}" realm)
PAGE=http://127.0.0.1:4001/openapi/other/createitem
echo "@redocly/framework $("${REALM[@]}" --version)"
set -m
"${REALM[@]}" develop --port 4001 >/dev/null 2>&1 &
SERVER_PID=$!
trap 'kill -- -$SERVER_PID' EXIT
for _ in {1..60}; do curl -fs -o /dev/null "$PAGE" && break; sleep 1; done
curl -fsS "$PAGE" | node page-fields.mjs
