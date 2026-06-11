#!/usr/bin/env bash
# integration.sh. Deep end to end test. Runs the real Foundry commands one after
# another in a sandbox and asserts that each one actually does what it claims,
# including the non destructive guarantee, which is proven by reproduction.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
skill="$(cd "$here/.." && pwd)"   # the foundry payload root
pass=0
fail=0
step()   { printf '\n>>> %s\n' "$1"; }
ok_run() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then pass=$((pass + 1)); printf '    ok    %s\n' "$d"; else fail=$((fail + 1)); printf '    FAIL  %s\n' "$d"; fi; }
no_run() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then fail=$((fail + 1)); printf '    FAIL  %s\n' "$d"; else pass=$((pass + 1)); printf '    ok    %s\n' "$d"; fi; }

sandbox="$(mktemp -d 2>/dev/null || echo "/tmp/foundry-it-$$")"
mkdir -p "$sandbox"
trap 'rm -rf "$sandbox"' EXIT

step "1. install foundry into a clean sandbox project"
bash "$skill/install.sh" --root "$sandbox/clean" >/dev/null 2>&1
ok_run "the single universal copy holds SKILL.md" test -f "$sandbox/clean/.agents/skills/foundry/SKILL.md"
ok_run "the .claude entry is a symlink" test -L "$sandbox/clean/.claude/skills/foundry"
ok_run "the .claude symlink reaches SKILL.md" test -e "$sandbox/clean/.claude/skills/foundry/SKILL.md"
ok_run "references resolve in the install" test -e "$sandbox/clean/.agents/skills/foundry/references/principles.md"
no_run "the install holds no duplicate nested skill" test -e "$sandbox/clean/.agents/skills/foundry/skills/foundry/SKILL.md"
no_run "the installed SKILL.md has no unexpanded skill dir variable" grep -q "CLAUDE_SKILL_DIR" "$sandbox/clean/.agents/skills/foundry/SKILL.md"

step "2. run doctor against the installed copy, not the source"
ok_run "the installed copy reports healthy" bash "$sandbox/clean/.agents/skills/foundry/scripts/doctor.sh"

step "3. run the eval harness from the installed copy, proving it is self contained"
ok_run "the installed harness reports zero failures" bash "$sandbox/clean/.agents/skills/foundry/evals/run-evals.sh"

step "4. a dry run must change nothing on disk"
bash "$skill/install.sh" --root "$sandbox/dry" --dry-run >/dev/null 2>&1
no_run "the dry run created no universal copy" test -e "$sandbox/dry/.agents"
no_run "the dry run created no client symlink" test -e "$sandbox/dry/.claude"

step "5. non destructive. a file you placed in the install is never deleted"
mkdir -p "$sandbox/userfile/.agents/skills/foundry"
echo "MINE" > "$sandbox/userfile/.agents/skills/foundry/my-notes.txt"
bash "$skill/install.sh" --root "$sandbox/userfile" >/dev/null 2>&1
ok_run "a file placed in the universal dir survives the install" test -f "$sandbox/userfile/.agents/skills/foundry/my-notes.txt"
ok_run "the file content is intact" grep -q MINE "$sandbox/userfile/.agents/skills/foundry/my-notes.txt"

step "6. non destructive. a foreign file or symlink in the way is backed up"
mkdir -p "$sandbox/keepdir/.claude/skills/foundry"
echo "KEEP" > "$sandbox/keepdir/.claude/skills/foundry/keep.txt"
bash "$skill/install.sh" --root "$sandbox/keepdir" >/dev/null 2>&1
ok_run "the prior real directory was moved to a backup" ls -d "$sandbox/keepdir/.claude/skills/foundry.bak."*
ok_run "the prior content survived in the backup" grep -q KEEP "$sandbox/keepdir/.claude/skills/foundry.bak."*/keep.txt
ok_run "the new entry is now our symlink" test -L "$sandbox/keepdir/.claude/skills/foundry"
mkdir -p "$sandbox/foreign/.claude/skills"
ln -sfn /tmp "$sandbox/foreign/.claude/skills/foundry"
bash "$skill/install.sh" --root "$sandbox/foreign" >/dev/null 2>&1
ok_run "a foreign symlink was backed up, not clobbered" ls -d "$sandbox/foreign/.claude/skills/foundry.bak."*
ok_run "our symlink now reaches the universal copy" test -e "$sandbox/foreign/.claude/skills/foundry/SKILL.md"

step "7. idempotency. a second install does not back up our own managed copy"
bash "$skill/install.sh" --root "$sandbox/clean" >/dev/null 2>&1
no_run "no backup of our own symlink appeared" ls -d "$sandbox/clean/.claude/skills/foundry.bak."*
no_run "no backup of our own universal copy appeared" ls -d "$sandbox/clean/.agents/skills/foundry.bak."*

step "8. the linters produce real findings on real inputs"
no_run "check-hook flags a real bad hook" bash "$skill/scripts/check-hook.sh" "$skill/evals/fixtures/hooks/bad/bad-hook.sh"
ok_run "check-hook passes a real clean hook" bash "$skill/scripts/check-hook.sh" "$skill/evals/fixtures/hooks/good/clean-hook.sh"
ok_run "check-skill passes the real skill" bash "$skill/scripts/check-skill.sh" "$skill"
no_run "check-command flags a thin command" bash "$skill/scripts/check-command.sh" "$skill/evals/fixtures/commands/bad/short-description.md"
ok_run "check-command passes a good command" bash "$skill/scripts/check-command.sh" "$skill/evals/fixtures/commands/good/audit-branch.md"

printf '\nfoundry integration: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
