#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

test_mocked_upload() (
  mkdir -p "$TMP/bin"
  cat > "$TMP/bin/curl" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$CURL_LOG"
if [[ " $* " == *" -X POST "* ]]; then
  printf '%s' '{"status":"ok","data":{"token":"initial-token"}}'
elif [[ " $* " == *" folderId=folder-123 "* ]]; then
  [[ " $* " == *" Authorization: Bearer guest-token "* ]] || exit 91
  printf '%s' '{"status":"ok","data":{"downloadPage":"https://gofile.io/d/test","parentFolder":"folder-123","guestToken":"guest-token"}}'
else
  [[ " $* " == *" Authorization: Bearer initial-token "* ]] || exit 92
  printf '%s' '{"status":"ok","data":{"downloadPage":"https://gofile.io/d/test","parentFolder":"folder-123","guestToken":"guest-token"}}'
fi
MOCK
  chmod +x "$TMP/bin/curl"
  export PATH="$TMP/bin:$PATH" CURL_LOG="$TMP/curl.log"
  printf one > "$TMP/mock-one.txt"
  printf two > "$TMP/mock-two.txt"

  output=$("$ROOT/gofile" -q "$TMP/mock-one.txt" "$TMP/mock-two.txt")
  [[ $output == https://gofile.io/d/test ]]
  [[ $(wc -l < "$CURL_LOG" | tr -d ' ') == 3 ]]
  grep -q -- '-X POST' "$CURL_LOG"
  grep -q -- 'folderId=folder-123' "$CURL_LOG"
  echo "ok: mocked two-file upload reuses one authenticated guest folder"
)

test_real_upload() {
  printf 'gofile-cli integration test one\n' > "$TMP/real-one.txt"
  printf 'gofile-cli integration test two\n' > "$TMP/real-two.txt"

  output=$("$ROOT/gofile" -q "$TMP/real-one.txt" "$TMP/real-two.txt")
  [[ $output =~ ^https://gofile\.io/d/[A-Za-z0-9_-]+$ ]]
  echo "ok: real two-file upload returned one Gofile folder URL"
}

test_mocked_upload
test_real_upload
