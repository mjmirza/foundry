#!/usr/bin/env bash
# check-docs.sh. Deep markdown hygiene. Finds broken local links, broken heading
# anchors, missing images, and orphan docs that nothing references. The orphan
# pass is the part most link checkers lack, the docs equivalent of dead code.
# Pure bash, no dependency, anchor-slug aware, skill-dir aware.
# Usage. check-docs.sh <dir> [--no-orphans] [--entry a.md,b.md]
# Exit 0 clean, 1 on a finding, fail open on a bad path.
set -uo pipefail

root="${1:-}"
[ -z "$root" ] && { echo "usage: check-docs.sh <dir> [--no-orphans] [--entry a.md,b.md]"; exit 0; }
[ -d "$root" ] || { echo "check-docs: $root is not a directory, skipping" >&2; exit 0; }
shift
no_orphans=0
extra_entries=""
while [ $# -gt 0 ]; do
  case "$1" in
    --no-orphans) no_orphans=1 ;;
    --entry) shift; extra_entries="${1:-}" ;;
    *) : ;;
  esac
  shift
done
root="$(cd "$root" && pwd)"

findings=0
report() { printf '%s  %s\n' "$1" "$2"; findings=$((findings + 1)); }

tmp="$(mktemp -d 2>/dev/null || echo "/tmp/check-docs-$$")"
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT

find "$root" -type f -name '*.md' -not -path '*/.git/*' -not -path '*/node_modules/*' | sort > "$tmp/mdlist"

# Honor a .check-docs-ignore at the root, one substring per line, so test data
# and generated docs can be excluded the way a .gitignore excludes files.
if [ -f "$root/.check-docs-ignore" ]; then
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    case "$pat" in '#'*) continue ;; esac
    grep -vF -- "$pat" "$tmp/mdlist" > "$tmp/m2" 2>/dev/null || true
    [ -f "$tmp/m2" ] && mv "$tmp/m2" "$tmp/mdlist"
  done < "$root/.check-docs-ignore"
fi

# strip_fences removes fenced code blocks but keeps inline code, because doc
# paths are often referenced inside inline code. strip_all also removes inline
# code, for link extraction where inline code would yield false positives.
strip_fences() { awk 'BEGIN{c=0} /^[[:space:]]*```/{c=!c; next} !c' "$1"; }
# shellcheck disable=SC2016  # the single quotes are the literal sed pattern, intentional
strip_all() { strip_fences "$1" | sed 's/`[^`]*`//g'; }
slugify() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 _-]//g; s/[ _]+/-/g; s/-+/-/g; s/^-+//; s/-+$//'; }

normpath() {
  local p="$1" out="" seg OLDIFS="$IFS"
  IFS=/
  # shellcheck disable=SC2086
  set -- $p
  IFS="$OLDIFS"
  for seg in "$@"; do
    case "$seg" in
      ''|.) ;;
      ..) out="${out%/*}" ;;
      *) out="$out/$seg" ;;
    esac
  done
  printf '%s' "${out:-/}"
}

heading_slugs() {
  strip_all "$1" | grep -E '^#{1,6}[[:space:]]+' | sed -E 's/^#+[[:space:]]+//; s/[[:space:]]+#+[[:space:]]*$//' | while IFS= read -r h; do slugify "$h"; done
}

# Only real markdown links and images, after stripping fenced and inline code.
extract_targets() { strip_all "$1" | grep -oE '\]\([^)]+\)' | sed -E 's/^\]\(//; s/\)$//'; }

clean_target() {
  local t="${1%% *}"
  t="${t//\$\{CLAUDE_SKILL_DIR\}\//}"
  t="${t//\$CLAUDE_SKILL_DIR\//}"
  printf '%s' "$t"
}

# Pass 1. broken links, anchors, images. Every link that resolves to a real file
# is recorded in the linked set, so the orphan pass can treat a real markdown
# link as reachability without guessing at path shape.
: > "$tmp/linked"
while IFS= read -r f; do
  fdir="$(dirname "$f")"
  while IFS= read -r raw; do
    [ -z "$raw" ] && continue
    t="$(clean_target "$raw")"
    case "$t" in
      http://*|https://*|mailto:*|tel:*|ftp://*|//*) continue ;;
      '#'*)
        anchor="${t#\#}"
        [ -z "$anchor" ] && continue
        heading_slugs "$f" | grep -Fxq "$anchor" || report "$f" "broken same file anchor, #$anchor"
        continue ;;
      ''|*'$'*|*'<'*|*'>'*|*'path/to'*) continue ;;
    esac
    file="${t%%#*}"
    anchor=""
    case "$t" in *'#'*) anchor="${t#*#}" ;; esac
    [ -z "$file" ] && continue
    target="$(normpath "$fdir/$file")"
    if [ ! -e "$target" ]; then
      report "$f" "broken link, target not found, $file"
      continue
    fi
    printf '%s\n' "$target" >> "$tmp/linked"
    if [ -n "$anchor" ] && printf '%s' "$file" | grep -qE '\.md$'; then
      heading_slugs "$target" | grep -Fxq "$anchor" || report "$f" "broken anchor, #$anchor not in $file"
    fi
  done < <(extract_targets "$f")
done < "$tmp/mdlist"

# Pass 2. orphan docs. A doc is an orphan when no other doc references its path.
# A reference is any mention of its path, a markdown link or an inline code path.
# Entry and convention files, plugin loaded dirs, and test data are exempt.
if [ "$no_orphans" -eq 0 ]; then
  if [ -f "$root/.docs-orphan-allow" ]; then cp "$root/.docs-orphan-allow" "$tmp/allow"; else : > "$tmp/allow"; fi
  if [ -n "$extra_entries" ]; then printf '%s\n' "$extra_entries" | tr ',' '\n' >> "$tmp/allow"; fi

  while IFS= read -r f; do
    base="$(basename "$f")"
    rel="${f#"$root"/}"
    case "$base" in
      README.md|SKILL.md|AGENTS.md|CHANGELOG.md|CONTRIBUTING.md|CODE_OF_CONDUCT.md|SECURITY.md|index.md) continue ;;
    esac
    case "$f" in */.github/*|*/commands/*|*/evals/*|*/fixtures/*) continue ;; esac
    grep -Fxq "$rel" "$tmp/allow" && continue
    grep -Fxq "$base" "$tmp/allow" && continue

    # A real markdown link resolving to this file makes it reachable. This is the
    # precise signal and covers a bare same dir link like guide.md.
    grep -Fxq "$f" "$tmp/linked" && continue

    # Fallback for references mentioned as inline code paths rather than links,
    # which is how a skill body points at its reference files. The key is the
    # last two path segments, specific enough to avoid matching a same named
    # file elsewhere.
    key="$(basename "$(dirname "$f")")/$base"
    reachable=0
    while IFS= read -r g; do
      [ "$g" = "$f" ] && continue
      if strip_fences "$g" | grep -Fq "$key"; then reachable=1; break; fi
    done < "$tmp/mdlist"
    [ "$reachable" -eq 0 ] && report "$f" "orphan doc, no other doc references $base. link it or add it to .docs-orphan-allow"
  done < "$tmp/mdlist"
fi

if [ "$findings" -gt 0 ]; then
  printf '\ncheck-docs: %s finding(s)\n' "$findings" >&2
  exit 1
fi
exit 0
