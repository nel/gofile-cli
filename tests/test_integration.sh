#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Two uploads are intentional: the second verifies that Gofile still accepts
# the guest token and folder ID returned by the first upload.
printf 'gofile-cli integration test one\n' > "$TMP/one.txt"
printf 'gofile-cli integration test two\n' > "$TMP/two.txt"

output=$("$ROOT/gofile" -q "$TMP/one.txt" "$TMP/two.txt")
[[ $output =~ ^https://gofile\.io/d/[A-Za-z0-9_-]+$ ]]

echo "ok: real two-file upload returned one Gofile folder URL"
