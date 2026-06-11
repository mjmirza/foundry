#!/usr/bin/env bash
set -uo pipefail
payload="$(cat)"
file="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')"
[ -z "$file" ] && exit 0
root="${CLAUDE_PROJECT_DIR:-$PWD}"
case "$file" in
  *.env) printf 'blocked %s under %s\n' "$file" "$root" >&2; exit 2 ;;
esac
exit 0
