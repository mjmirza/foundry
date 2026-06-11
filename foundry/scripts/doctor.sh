#!/usr/bin/env bash
# doctor.sh. Check that a Foundry install or checkout is healthy.
# Verifies both SKILL.md layouts, the 12 references, the references symlink,
# version sync across the four manifests, the linters, and the eval harness.
# Exit 0 when healthy, exit 1 when an issue is found, fail open on a bad path.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
skill="$(cd "$here/.." && pwd)"          # the foundry payload root
repo="$(cd "$skill/.." && pwd)"          # the repo root
issues=0
note() { printf 'fail  %s\n' "$1"; issues=$((issues + 1)); }
ok()   { printf 'ok    %s\n' "$1"; }

[ -f "$skill/SKILL.md" ] && ok "plugin format SKILL.md present" || note "missing SKILL.md"
[ -f "$skill/skills/foundry/SKILL.md" ] && ok "skills format SKILL.md present" || note "missing skills format SKILL.md"

missing=0
for r in principles skills hooks mcp-servers subagents commands context-engineering settings-and-config testing-and-evals security portability anti-patterns; do
  [ -f "$skill/references/$r.md" ] || { note "missing reference $r.md"; missing=1; }
done
[ "$missing" -eq 0 ] && ok "all 12 references present"

if [ -L "$skill/skills/foundry/references" ] && [ -e "$skill/skills/foundry/references/principles.md" ]; then
  ok "references symlink resolves"
else
  note "references symlink does not resolve"
fi

# Version sync. The marketplace manifest is a repo level file and is absent in an
# installed skill, so it is compared only when present.
get_ver() { grep -oE '"version": *"[0-9][0-9A-Za-z.+-]*"' "$1" 2>/dev/null | head -n1 | grep -oE '[0-9][0-9A-Za-z.+-]*'; }
get_fm()  { awk -F'"' '/^[[:space:]]*version:/ {print $2; exit}' "$1" 2>/dev/null; }
v2="$(get_ver "$skill/.claude-plugin/plugin.json")"
v3="$(get_fm "$skill/SKILL.md")"
v4="$(get_fm "$skill/skills/foundry/SKILL.md")"
mk="$repo/.claude-plugin/marketplace.json"
if [ -f "$mk" ]; then v1="$(get_ver "$mk")"; else v1="$v2"; fi
if [ -n "$v2" ] && [ "$v1" = "$v2" ] && [ "$v2" = "$v3" ] && [ "$v3" = "$v4" ]; then
  ok "manifest versions all match at $v2"
else
  note "manifest version drift, marketplace=$v1 plugin=$v2 skill=$v3 skills=$v4"
fi

for l in check-skill check-hook check-mcp; do
  [ -x "$skill/scripts/$l.sh" ] && ok "linter $l is executable" || note "linter $l is not executable"
done

[ -x "$skill/evals/run-evals.sh" ] && ok "eval harness present" || note "eval harness missing or not executable"

echo
if [ "$issues" -eq 0 ]; then
  echo "foundry doctor: healthy"
  exit 0
fi
echo "foundry doctor: $issues issue(s)"
exit 1
