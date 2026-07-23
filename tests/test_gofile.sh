#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
export GOFILE_CONFIG="$TMP/no-config"

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
  cat > "$TMP/bin/gofile-test-open" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$1" >> "$OPEN_LOG"
MOCK
  chmod +x "$TMP/bin/curl"
  chmod +x "$TMP/bin/gofile-test-open"
  export PATH="$TMP/bin:$PATH" CURL_LOG="$TMP/curl.log" OPEN_LOG="$TMP/open.log"
  printf one > "$TMP/mock-one.txt"
  printf two > "$TMP/mock-two.txt"

  output=$("$ROOT/gofile" -q "$TMP/mock-one.txt" "$TMP/mock-two.txt")
  [[ $output == https://gofile.io/d/test ]]
  [[ $(wc -l < "$CURL_LOG" | tr -d ' ') == 3 ]]
  grep -q -- '-X POST' "$CURL_LOG"
  grep -q -- 'folderId=folder-123' "$CURL_LOG"
  echo "ok: mocked two-file upload reuses one authenticated guest folder"

  : > "$CURL_LOG"
  printf one > "$TMP/The-Show_Name.S01E01.1080p.mkv"
  printf two > "$TMP/The-Show_Name.S01E02.1080p.mkv"
  output=$(GOFILE_EMAIL_TO=26verol@seznam.cz \
    GOFILE_OPEN_COMMAND=gofile-test-open \
    "$ROOT/gofile" -q \
    "$TMP/The-Show_Name.S01E01.1080p.mkv" \
    "$TMP/The-Show_Name.S01E02.1080p.mkv")
  [[ $output == https://gofile.io/d/test ]]
  [[ -s $OPEN_LOG ]]
  compose_url=$(tail -n 1 "$OPEN_LOG")
  [[ $compose_url == mailto:26verol%40seznam.cz\\?* ]]
  [[ $compose_url == *'subject=The%20Show%20Name%20%E2%80%94%20S01E01%2C%20S01E02'* ]]
  [[ $compose_url == *'body=https%3A%2F%2Fgofile.io%2Fd%2Ftest'* ]]
  echo "ok: mailto draft uses the configured recipient, clean subject, and folder URL"

  cat > "$TMP/test.gofile" <<'CONFIG'
EMAIL_TO=from-config@example.com
EMAIL_COMPOSE_URL=https://webmail.example/compose?recipient={to}&title={subject}&content={body}
EPISODE_LIST_LIMIT=1
CONFIG
  : > "$OPEN_LOG"
  GOFILE_CONFIG="$TMP/test.gofile" \
    GOFILE_OPEN_COMMAND=gofile-test-open \
    "$ROOT/gofile" -q \
    "$TMP/The-Show_Name.S01E01.1080p.mkv" \
    "$TMP/The-Show_Name.S01E02.1080p.mkv" >/dev/null
  compose_url=$(tail -n 1 "$OPEN_LOG")
  [[ $compose_url == https://webmail.example/compose\\?* ]]
  [[ $compose_url == *'recipient=from-config%40example.com'* ]]
  [[ $compose_url == *'title=The%20Show%20Name%20%E2%80%94%20Season%201'* ]]
  [[ $compose_url == *'content=https%3A%2F%2Fgofile.io%2Fd%2Ftest'* ]]
  echo "ok: custom webmail template applies config values and season summary"

  printf movie > "$TMP/Some.Movie.2025.2160p.WEB-DL.mkv"
  : > "$OPEN_LOG"
  GOFILE_EMAIL_TO=26verol@seznam.cz \
    GOFILE_OPEN_COMMAND=gofile-test-open \
    "$ROOT/gofile" -q "$TMP/Some.Movie.2025.2160p.WEB-DL.mkv" >/dev/null
  compose_url=$(tail -n 1 "$OPEN_LOG")
  [[ $compose_url == *'subject=Some%20Movie%20%282025%29'* ]]
  echo "ok: movie release metadata is removed from the subject"

  : > "$OPEN_LOG"
  GOFILE_EMAIL_TO=26verol@seznam.cz \
    GOFILE_OPEN_COMMAND=gofile-test-open \
    "$ROOT/gofile" -nq "$TMP/The-Show_Name.S01E01.1080p.mkv" >/dev/null
  [[ ! -s $OPEN_LOG ]]
  echo "ok: -n suppresses email composition"
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
