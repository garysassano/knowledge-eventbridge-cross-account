#!/usr/bin/env bash
# Checks that every markdown link in the repo returns HTTP 200 without redirecting to a different page.
set -euo pipefail

cd "$(dirname "$0")/.."

status=0
while IFS= read -r url; do
  result=$(curl -sS -o /dev/null -L --max-time 30 -w '%{http_code} %{url_effective}' "$url" 2>/dev/null || echo "000 error")
  code=${result%% *}
  final=${result#* }
  if [[ $code != 200 || ${final%%#*} != "${url%%#*}" ]]; then
    printf 'BAD %s -> %s\n' "$url" "$result"
    status=1
  fi
done < <(rg -o --no-filename -r '$1' '\]\((https?://[^)]+)\)' -- *.md docs/*.md | sort -u)

exit "$status"
