#!/usr/bin/env bash
# install.sh. Install the Foundry skill the correct way, and only the correct way.
# It writes the single universal copy at .agents/skills/foundry, which Codex,
# Gemini, Cursor, and Cline all read directly, and adds one symlink at
# .claude/skills/foundry for Claude Code, the one client that does not read the
# universal path. It never deletes a file you put there. Anything in the way is
# kept with a .bak suffix. The read paths per client live in data/install-paths.json.
# Usage. install.sh [--user | --project] [--root DIR] [--dry-run]
#   --user      install for all your projects, under your home directory
#   --project   install for the current project, the default
#   --root DIR  install under DIR, requires a value, used for tests
#   --dry-run   print what would happen, change nothing
set -uo pipefail

src="$(cd "$(dirname "$0")" && pwd)"
scope="project"
dry=0
root=""
while [ $# -gt 0 ]; do
  case "$1" in
    --user) scope="user" ;;
    --project) scope="project" ;;
    --root) shift; root="${1:-}"; [ -n "$root" ] || { echo "error. --root requires a directory" >&2; exit 2; } ;;
    --dry-run) dry=1 ;;
    -h|--help) echo "usage. install.sh [--user|--project] [--root DIR] [--dry-run]"; exit 0 ;;
    *) echo "error. unknown argument $1" >&2; exit 2 ;;
  esac
  shift
done
if [ -z "$root" ]; then
  if [ "$scope" = "user" ]; then root="$HOME"; else root="$PWD"; fi
fi

run() { if [ "$dry" -eq 1 ]; then printf 'DRY  %s\n' "$*"; else "$@"; fi; }

target_link="../../.agents/skills/foundry"

# Move aside anything in the way that is not our own managed symlink. Never delete.
backup() {
  local p="$1"
  local stamp
  stamp="$(date +%Y%m%d%H%M%S 2>/dev/null || echo prev)"
  if [ -L "$p" ]; then
    if [ "$(readlink "$p" 2>/dev/null)" != "$target_link" ]; then
      run mv "$p" "$p.bak.$stamp"
    fi
  elif [ -e "$p" ]; then
    run mv "$p" "$p.bak.$stamp"
  fi
}

universal="$root/.agents/skills/foundry"
echo "installing foundry into $root"
run mkdir -p "$universal"

# Refresh our managed copy without --delete, so a file you placed in the install
# is never removed. Exclude the nested skills format copy so the install holds
# exactly one foundry skill, with relative reference paths that resolve anywhere.
if command -v rsync >/dev/null 2>&1; then
  # The leading slash anchors the exclude to the top level, so the nested skills
  # format copy is dropped while evals/fixtures/skills and any other nested
  # skills directory are kept.
  run rsync -a --exclude '/skills/' "$src/" "$universal/"
else
  for entry in "$src"/* "$src"/.[!.]*; do
    [ -e "$entry" ] || continue
    case "$(basename "$entry")" in skills) continue ;; esac
    run cp -R "$entry" "$universal/"
  done
fi

run mkdir -p "$root/.claude/skills"
link="$root/.claude/skills/foundry"
backup "$link"
run ln -sfn "$target_link" "$link"
printf 'linked  %s\n' "$link"

echo
echo "done. the skill lives once at $universal."
echo "Claude Code reads it through $root/.claude/skills/foundry."
echo "Codex, Gemini, Cursor, and Cline read $root/.agents/skills/ directly."
echo "Copilot uses AGENTS.md at the repo root. See references/portability.md."
echo "anything already in the way was kept with a .bak suffix. nothing was deleted."
exit 0
