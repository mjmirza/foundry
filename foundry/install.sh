#!/usr/bin/env bash
# install.sh. Install the Foundry skill the correct way. Writes the universal
# .agents/skills/foundry copy and creates the per assistant symlink for each
# common client, non destructively. This is the portability rule Foundry
# teaches, applied to itself.
# Usage. install.sh [--user | --project] [--root DIR] [--dry-run]
#   --user      install for all your projects, under your home directory
#   --project   install for the current project, the default
#   --root DIR  install under DIR, used for tests
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
    --root) shift; root="${1:-}" ;;
    --dry-run) dry=1 ;;
    -h|--help) echo "usage: install.sh [--user|--project] [--root DIR] [--dry-run]"; exit 0 ;;
    *) echo "unknown arg $1" >&2; exit 0 ;;
  esac
  shift
done
if [ -z "$root" ]; then
  if [ "$scope" = "user" ]; then root="$HOME"; else root="$PWD"; fi
fi

run() { if [ "$dry" -eq 1 ]; then printf 'DRY  %s\n' "$*"; else "$@"; fi; }

backup() {
  # Back up a path that exists and is not already our symlink. Never delete.
  local p="$1"
  if [ -e "$p" ] && [ ! -L "$p" ]; then
    run mv "$p" "$p.bak.$(date +%s 2>/dev/null || echo prev)"
  fi
}

universal="$root/.agents/skills/foundry"
echo "installing foundry into $root"
# The universal copy is ours to manage, so refresh it in place rather than back
# it up. This keeps a re-install idempotent instead of piling up backups.
run mkdir -p "$universal"
if command -v rsync >/dev/null 2>&1; then
  run rsync -a --delete "$src/" "$universal/"
else
  run cp -R "$src/." "$universal/"
fi

# Every client skills directory is two levels under the root, so the relative
# path back to the universal copy is the same for all of them.
rel="../../.agents/skills/foundry"
for d in .claude/skills .codex/skills .gemini/skills .cursor/skills .cline/skills; do
  dir="$root/$d"
  link="$dir/foundry"
  run mkdir -p "$dir"
  backup "$link"
  run ln -sfn "$rel" "$link"
  printf 'linked  %s\n' "$link"
done

echo
echo "done. the skill lives once at $universal and each client reads it through a symlink."
echo "nothing was overwritten. any prior file was kept with a .bak suffix."
exit 0
