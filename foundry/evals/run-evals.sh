#!/usr/bin/env bash
# run-evals.sh. Prove the Foundry linters catch every bad fixture and pass every
# good one. This is the harness the reference repo lacks. Any secret shaped
# fixture is assembled at runtime, so no secret is ever committed.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
scripts="$here/../scripts"
fx="$here/fixtures"
pass=0
fail=0

expect() {
  # expect <description> <expected-exit> <command...>
  local desc="$1" want="$2"
  shift 2
  "$@" >/dev/null 2>&1
  local got=$?
  if [ "$got" -eq "$want" ]; then
    pass=$((pass + 1))
    printf 'ok    %s\n' "$desc"
  else
    fail=$((fail + 1))
    printf 'FAIL  %s, want exit %s, got %s\n' "$desc" "$want" "$got"
  fi
}

for f in "$fx"/hooks/good/*.sh; do
  expect "hook good $(basename "$f")" 0 bash "$scripts/check-hook.sh" "$f"
done
for f in "$fx"/hooks/bad/*.sh; do
  expect "hook bad $(basename "$f")" 1 bash "$scripts/check-hook.sh" "$f"
done

for d in "$fx"/skills/good/*/; do
  expect "skill good $(basename "$d")" 0 bash "$scripts/check-skill.sh" "$d"
done
for d in "$fx"/skills/bad/*/; do
  expect "skill bad $(basename "$d")" 1 bash "$scripts/check-skill.sh" "$d"
done

for f in "$fx"/mcp/good/*.json; do
  expect "mcp good $(basename "$f")" 0 bash "$scripts/check-mcp.sh" "$f"
done
for f in "$fx"/mcp/bad/*.json; do
  expect "mcp bad $(basename "$f")" 1 bash "$scripts/check-mcp.sh" "$f"
done

for f in "$fx"/commands/good/*.md; do
  expect "command good $(basename "$f")" 0 bash "$scripts/check-command.sh" "$f"
done
for f in "$fx"/commands/bad/*.md; do
  expect "command bad $(basename "$f")" 1 bash "$scripts/check-command.sh" "$f"
done

# Docs hygiene. Build a clean set and a broken set at runtime, so no broken
# markdown is ever committed.
dtmp="$(mktemp -d 2>/dev/null || echo "/tmp/foundry-docs-$$")"
mkdir -p "$dtmp/good"
printf '# Home\n\nSee [the guide](guide.md).\n' > "$dtmp/good/README.md"
printf '# Guide\n\nReal content here.\n' > "$dtmp/good/guide.md"
expect "docs good set is clean" 0 bash "$scripts/check-docs.sh" "$dtmp/good"
mkdir -p "$dtmp/bad"
printf '# Home\n\nSee [missing](nope.md) and [bad anchor](guide.md#nope).\n' > "$dtmp/bad/README.md"
printf '# Guide\n\nReal content here.\n' > "$dtmp/bad/guide.md"
printf '# Orphan\n\nNobody references this doc.\n' > "$dtmp/bad/orphan.md"
expect "docs bad set is caught" 1 bash "$scripts/check-docs.sh" "$dtmp/bad"
rm -rf "$dtmp"

# Secret detection. Assemble the fixture at runtime so no secret is committed.
tmp="$(mktemp 2>/dev/null || echo /tmp/foundry-eval-$$.json)"
fake="sk-$(printf '%040d' 0 | tr '0' 'A')"
printf '{ "mcpServers": { "x": { "command": "node", "args": ["s.js"], "env": { "API_KEY": "%s" } } } }\n' "$fake" > "$tmp"
expect "mcp bad assembled-secret" 1 bash "$scripts/check-mcp.sh" "$tmp"
rm -f "$tmp"

# Health check. This checkout must pass doctor.
expect "doctor on this checkout" 0 bash "$scripts/doctor.sh"

# Installer smoke. Install into a temp root, then confirm the universal copy and
# a per assistant symlink both resolve. Clean up afterward.
itmp="$(mktemp -d 2>/dev/null || echo "/tmp/foundry-install-$$")"
mkdir -p "$itmp"
bash "$scripts/../install.sh" --root "$itmp" >/dev/null 2>&1
if [ -f "$itmp/.agents/skills/foundry/SKILL.md" ] && [ -L "$itmp/.claude/skills/foundry" ] && [ -e "$itmp/.claude/skills/foundry/SKILL.md" ]; then
  pass=$((pass + 1)); printf 'ok    installer writes the universal copy and a working symlink\n'
else
  fail=$((fail + 1)); printf 'FAIL  installer did not produce the universal copy plus a working symlink\n'
fi
rm -rf "$itmp"

printf '\nfoundry evals: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
