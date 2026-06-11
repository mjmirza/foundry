#!/usr/bin/env bash
# doctor.sh. Check that a Foundry source checkout or an installed copy is healthy.
# A source checkout carries both SKILL.md layouts and the references symlink. An
# installed copy carries a single skill with relative paths, so the nested skills
# format layout is checked only when it is present.
# Exit 0 when healthy, exit 1 when an issue is found, fail open on a bad path.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
skill="$(cd "$here/.." && pwd)"          # the foundry payload root
repo="$(cd "$skill/.." && pwd)"          # the repo root, when run from a checkout
issues=0
note() { printf 'fail  %s\n' "$1"; issues=$((issues + 1)); }
ok()   { printf 'ok    %s\n' "$1"; }

if [ -f "$skill/SKILL.md" ]; then ok "SKILL.md present"; else note "missing SKILL.md"; fi

missing=0
for r in principles skills hooks mcp-servers subagents commands context-engineering settings-and-config testing-and-evals security portability anti-patterns; do
  if [ ! -f "$skill/references/$r.md" ]; then note "missing reference $r.md"; missing=1; fi
done
if [ "$missing" -eq 0 ]; then ok "all 12 references present"; fi

# The nested skills format layout is optional. It exists in a source checkout and
# is absent in a single skill install.
have_skills_format=0
if [ -d "$skill/skills/foundry" ]; then
  have_skills_format=1
  if [ -f "$skill/skills/foundry/SKILL.md" ]; then ok "skills format SKILL.md present"; else note "missing skills format SKILL.md"; fi
  if [ -L "$skill/skills/foundry/references" ] && [ -e "$skill/skills/foundry/references/principles.md" ]; then
    ok "references symlink resolves"
  else
    note "references symlink does not resolve"
  fi
else
  ok "single skill install layout"
fi

# Version sync. The marketplace manifest and the skills format SKILL.md are not
# present in an installed copy, so each is compared only when present.
get_ver() { grep -oE '"version": *"[0-9][0-9A-Za-z.+-]*"' "$1" 2>/dev/null | head -n1 | grep -oE '[0-9][0-9A-Za-z.+-]*'; }
get_fm()  { awk -F'"' '/^[[:space:]]*version:/ {print $2; exit}' "$1" 2>/dev/null; }
v_plugin="$(get_fm "$skill/SKILL.md")"
ref="$v_plugin"
drift=0
pj="$skill/.claude-plugin/plugin.json"
mk="$repo/.claude-plugin/marketplace.json"
sf="$skill/skills/foundry/SKILL.md"
if [ -f "$pj" ] && [ "$(get_ver "$pj")" != "$ref" ]; then drift=1; fi
if [ -f "$mk" ] && [ "$(get_ver "$mk")" != "$ref" ]; then drift=1; fi
if [ "$have_skills_format" -eq 1 ] && [ -f "$sf" ] && [ "$(get_fm "$sf")" != "$ref" ]; then drift=1; fi
if [ -n "$ref" ] && [ "$drift" -eq 0 ]; then
  ok "manifest versions all match at $ref"
else
  note "manifest version drift, reference is $ref"
fi

for l in check-skill check-hook check-mcp check-command; do
  if [ -x "$skill/scripts/$l.sh" ]; then ok "linter $l is executable"; else note "linter $l is not executable"; fi
done

if [ -x "$skill/evals/run-evals.sh" ]; then ok "eval harness present"; else note "eval harness missing or not executable"; fi

echo
if [ "$issues" -eq 0 ]; then
  echo "foundry doctor: healthy"
  exit 0
fi
echo "foundry doctor: $issues issue(s)"
exit 1
