#!/usr/bin/env bash
# check-mcp.sh. Lint an MCP server config for the common mistakes.
# Usage. check-mcp.sh <path-to-mcp-config.json>
# Exit 0 when clean or when the input cannot be read (fail open).
# Exit 1 when at least one finding is reported.
set -uo pipefail

file="${1:-}"
[ -z "$file" ] && { echo "usage: check-mcp.sh <mcp-config.json>" >&2; exit 0; }
[ -r "$file" ] || { echo "check-mcp: cannot read $file, skipping" >&2; exit 0; }

findings=0
report() { printf '%s:%s  %s\n' "$file" "$1" "$2"; findings=$((findings + 1)); }

# 1. Inline secrets must never appear in a committed config.
while IFS=: read -r ln _; do
  report "$ln" "looks like an inline secret. read credentials from the environment, never inline a key"
done < <(grep -nE 'sk-[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|[Bb]earer[[:space:]]+[A-Za-z0-9._-]{16,}' "$file")

# 2. Unpinned npx package floats the version. Checked at file level, because the
# version sits on the args line, not the command line.
if grep -qE '"npx"|[[:space:]]npx[[:space:]]' "$file" && ! grep -qE '@[0-9]' "$file"; then
  report 0 "an npx server has no pinned @version. pin a version so the install is reproducible"
fi

# 3. A server must define how it starts.
if ! grep -qE '"command"|"url"|"args"' "$file"; then
  report 0 "no command or url found. an MCP entry must declare how the server starts"
fi

if [ "$findings" -gt 0 ]; then
  printf '\ncheck-mcp: %s finding(s) in %s\n' "$findings" "$file" >&2
  exit 1
fi
exit 0
