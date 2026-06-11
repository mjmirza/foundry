#!/usr/bin/env bash
# check-command.sh. Lint a slash command markdown file for the common mistakes.
# Usage. check-command.sh <path-to-command.md>
# Exit 0 when clean or when the input cannot be read (fail open).
# Exit 1 when at least one finding is reported.
set -uo pipefail

file="${1:-}"
[ -z "$file" ] && { echo "usage: check-command.sh <command.md>" >&2; exit 0; }
[ -r "$file" ] || { echo "check-command: cannot read $file, skipping" >&2; exit 0; }

findings=0
report() { printf '%s  %s\n' "$file" "$1"; findings=$((findings + 1)); }

# 1. Frontmatter must open on line 1 and close. Without it the command does not
# appear in the slash menu.
if [ "$(head -n1 "$file")" != "---" ]; then
  report "missing YAML frontmatter. a command without frontmatter will not appear in the slash menu"
else
  if ! awk 'NR>1 && $0=="---" {found=1; exit} END {exit !found}' "$file"; then
    report "frontmatter is not closed with a second --- line"
  fi
fi

# 2. A description is required, or the command is invisible in autocomplete.
desc="$(awk -F'description: *' '/^description:/ {print $2; exit}' "$file")"
if [ -z "$desc" ]; then
  report "no description field. the command will be invisible in autocomplete"
elif [ "${#desc}" -lt 10 ]; then
  report "description is very short. say what the command does so a user can find it"
fi

if [ "$findings" -gt 0 ]; then
  printf '\ncheck-command: %s finding(s) in %s\n' "$findings" "$file" >&2
  exit 1
fi
exit 0
