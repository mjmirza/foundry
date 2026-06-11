#!/usr/bin/env bash
# check-hook.sh. Lint a shell hook for the common authoring mistakes.
# Usage. check-hook.sh <path-to-hook.sh>
# Exit 0 when clean or when the input cannot be read (fail open).
# Exit 1 when at least one finding is reported.
set -uo pipefail

file="${1:-}"
[ -z "$file" ] && { echo "usage: check-hook.sh <hook.sh>" >&2; exit 0; }
[ -r "$file" ] || { echo "check-hook: cannot read $file, skipping" >&2; exit 0; }

findings=0
report() { printf '%s:%s  %s\n' "$file" "$1" "$2"; findings=$((findings + 1)); }

# 1. Shebang must be the env bash form.
first="$(head -n1 "$file")"
if [ "$first" != "#!/usr/bin/env bash" ]; then
  report 1 "first line should be #!/usr/bin/env bash"
fi

# 2. set -e is banned. It can swallow an intended exit 2 block.
while IFS=: read -r ln _; do
  report "$ln" "uses set -e, which can swallow an exit 2 block. use set -uo pipefail"
done < <(grep -nE '^[[:space:]]*set[[:space:]]+-[a-z]*e' "$file")

# 3. set -uo pipefail should be present near the top.
if ! grep -qE '^[[:space:]]*set[[:space:]]+-[a-z]*u[a-z]*[[:space:]]+(-o[[:space:]]+)?pipefail|^[[:space:]]*set[[:space:]]+-uo[[:space:]]+pipefail' "$file"; then
  report 0 "missing set -uo pipefail near the top"
fi

# 4. PCRE escapes fail silently on BSD grep and sed.
while IFS=: read -r ln _; do
  report "$ln" "PCRE escape like backslash s or d. use a POSIX class such as [[:space:]] or [[:digit:]]"
done < <(grep -nE '\\[sdwSDW]' "$file")

# 5. The removed env var must not be used.
while IFS=: read -r ln _; do
  report "$ln" "reads removed env var CLAUDE_TOOL_INPUT. parse the event payload from stdin as JSON"
done < <(grep -nE 'CLAUDE_TOOL_INPUT' "$file")

# 6. A hook that reads tool_input or tool_name should read stdin.
if grep -qE 'tool_input|tool_name' "$file"; then
  if ! grep -qE '\$\(cat\)|<&0|read[[:space:]]|cat[[:space:]]*$|jq[[:space:]]' "$file"; then
    report 0 "references the tool payload but never reads stdin. read the payload with cat or jq"
  fi
fi

# 7. Bare $PWD as a project anchor is fragile in nested invocations.
# shellcheck disable=SC2016  # the single quotes are the literal grep pattern, intentional
while IFS=: read -r ln _; do
  report "$ln" "anchors on bare \$PWD. use \${CLAUDE_PROJECT_DIR:-\$PWD} for the project root"
done < <(grep -nE '\$PWD' "$file" | grep -vE 'CLAUDE_PROJECT_DIR')

if [ "$findings" -gt 0 ]; then
  printf '\ncheck-hook: %s finding(s) in %s\n' "$findings" "$file" >&2
  exit 1
fi
exit 0
