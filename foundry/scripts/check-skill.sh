#!/usr/bin/env bash
# check-skill.sh. Lint a SKILL.md for the common authoring mistakes.
# Usage. check-skill.sh <path-to-SKILL.md-or-skill-dir>
# Exit 0 when clean or when the input cannot be read (fail open).
# Exit 1 when at least one finding is reported.
set -uo pipefail

arg="${1:-}"
[ -z "$arg" ] && { echo "usage: check-skill.sh <SKILL.md or skill dir>" >&2; exit 0; }
if [ -d "$arg" ]; then file="$arg/SKILL.md"; else file="$arg"; fi
[ -r "$file" ] || { echo "check-skill: cannot read $file, skipping" >&2; exit 0; }

dir="$(cd "$(dirname "$file")" && pwd)"
base="$(basename "$dir")"
findings=0
report() { printf '%s  %s\n' "$file" "$1"; findings=$((findings + 1)); }

# 1. Frontmatter must open on line 1 and close.
if [ "$(head -n1 "$file")" != "---" ]; then
  report "missing YAML frontmatter. the first line should be ---"
else
  if ! awk 'NR>1 && $0=="---" {found=1; exit} END {exit !found}' "$file"; then
    report "frontmatter is not closed with a second --- line"
  fi
fi

# 2. name field present and matching the directory.
name="$(awk -F': *' '/^name:/ {print $2; exit}' "$file" | tr -d '"' | tr -d "[:space:]")"
if [ -z "$name" ]; then
  report "frontmatter has no name field. the skill is invisible to the loader"
elif [ "$name" != "$base" ]; then
  report "name '$name' does not match the directory '$base'"
fi

# 3. description present and not a thin title.
desc="$(awk -F'description: *' '/^description:/ {print $2; exit}' "$file")"
if [ -z "$desc" ]; then
  report "frontmatter has no description. the router cannot trigger the skill"
elif [ "${#desc}" -lt 40 ]; then
  report "description is very short. write a third person router with concrete triggers and a when to use"
fi

# 4. Referenced files must exist.
while read -r ref; do
  rel="${ref#\$\{CLAUDE_SKILL_DIR\}/}"
  rel="${rel#./}"
  [ -e "$dir/$rel" ] || report "references a missing file: $rel"
done < <(grep -oE '(\$\{CLAUDE_SKILL_DIR\}/|\b)references/[A-Za-z0-9_-]+\.md' "$file" | sort -u)

# 5. Entry file token budget. Large bodies cost tokens on every invocation.
bytes="$(wc -c < "$file" | tr -d '[:space:]')"
if [ "${bytes:-0}" -gt 12000 ]; then
  report "SKILL.md is large at $bytes bytes. move detail into reference files and load on demand"
fi

if [ "$findings" -gt 0 ]; then
  printf '\ncheck-skill: %s finding(s) in %s\n' "$findings" "$file" >&2
  exit 1
fi
exit 0
