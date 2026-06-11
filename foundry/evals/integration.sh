#!/usr/bin/env bash
# integration.sh. Deep end to end test. Runs the real Foundry commands one after
# another in a sandbox and asserts that each one actually does what it claims.
# This is the difference between shipping a command and proving it performs.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
skill="$(cd "$here/.." && pwd)"   # the foundry payload root
pass=0
fail=0
step()   { printf '\n>>> %s\n' "$1"; }
# ok_run expects the command to succeed. no_run expects it to fail. No eval.
ok_run() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then pass=$((pass + 1)); printf '    ok    %s\n' "$d"; else fail=$((fail + 1)); printf '    FAIL  %s\n' "$d"; fi; }
no_run() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then fail=$((fail + 1)); printf '    FAIL  %s\n' "$d"; else pass=$((pass + 1)); printf '    ok    %s\n' "$d"; fi; }

sandbox="$(mktemp -d 2>/dev/null || echo "/tmp/foundry-it-$$")"
mkdir -p "$sandbox"
trap 'rm -rf "$sandbox"' EXIT

step "1. install foundry into a clean sandbox project"
bash "$skill/install.sh" --root "$sandbox/clean" >/dev/null 2>&1
ok_run "the single universal copy holds SKILL.md" test -f "$sandbox/clean/.agents/skills/foundry/SKILL.md"
for a in claude codex gemini cursor cline; do
  ok_run "the .$a entry is a symlink" test -L "$sandbox/clean/.$a/skills/foundry"
  ok_run "the .$a symlink reaches SKILL.md" test -e "$sandbox/clean/.$a/skills/foundry/SKILL.md"
done
ok_run "the nested references symlink resolves in the install" test -e "$sandbox/clean/.agents/skills/foundry/skills/foundry/references/principles.md"

step "2. run doctor against the installed copy, not the source"
ok_run "the installed copy reports healthy" bash "$sandbox/clean/.agents/skills/foundry/scripts/doctor.sh"

step "3. run the eval harness from the installed copy, proving it is self contained"
ok_run "the installed harness reports zero failures" bash "$sandbox/clean/.agents/skills/foundry/evals/run-evals.sh"

step "4. a dry run must change nothing on disk"
bash "$skill/install.sh" --root "$sandbox/dry" --dry-run >/dev/null 2>&1
no_run "the dry run created no universal copy" test -e "$sandbox/dry/.agents"
no_run "the dry run created no client symlink" test -e "$sandbox/dry/.claude"

step "5. a real file already in the way is backed up, never deleted"
mkdir -p "$sandbox/keep/.claude/skills/foundry"
echo "MINE" > "$sandbox/keep/.claude/skills/foundry/notes.txt"
bash "$skill/install.sh" --root "$sandbox/keep" >/dev/null 2>&1
ok_run "the prior real directory was moved to a backup" ls -d "$sandbox/keep/.claude/skills/foundry.bak."*
ok_run "the prior content survived in the backup" grep -q MINE "$sandbox/keep/.claude/skills/foundry.bak."*/notes.txt
ok_run "the new entry is now our symlink" test -L "$sandbox/keep/.claude/skills/foundry"

step "6. a second install is idempotent, it does not back up our own managed copy"
bash "$skill/install.sh" --root "$sandbox/clean" >/dev/null 2>&1
no_run "no backup of our own symlink appeared" ls -d "$sandbox/clean/.claude/skills/foundry.bak."*
no_run "no backup of our own universal copy appeared" ls -d "$sandbox/clean/.agents/skills/foundry.bak."*

step "7. the linters produce real findings on real inputs"
no_run "check-hook flags a real bad hook" bash "$skill/scripts/check-hook.sh" "$skill/evals/fixtures/hooks/bad/bad-hook.sh"
ok_run "check-hook passes a real clean hook" bash "$skill/scripts/check-hook.sh" "$skill/evals/fixtures/hooks/good/clean-hook.sh"
ok_run "check-skill passes the real skill" bash "$skill/scripts/check-skill.sh" "$skill"

printf '\nfoundry integration: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
