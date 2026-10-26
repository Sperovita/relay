#!/usr/bin/env bash
# Drop relay into a project, or compare and update one, from the template next to this script.
# The /relay-init skill gets everything it needs from the bundle through this script's output, so it never
# reads files outside the project it runs in (many projects deny that).
# Usage:
#   init.sh DIR                  copy missing template files, never overwriting; for an AGENTS.md or
#                                .gitattributes that already existed, print the template text to merge
#   init.sh --show FILE          print a template file, by its path in the project
#   init.sh --diff DIR           list relay-owned files that are new or changed in the template, with diffs,
#                                and print the template's AGENTS.md pointer block if the project's differs
#   init.sh --apply DIR FILE...  copy the named relay-owned template files over the project's copies
# Relay-owned: every template file except AGENTS.md, CLAUDE.md, relay/STATUS.md and .gitkeep files.
# A trailing .tmpl is dropped on copy: the installed /relay-init bundle stores the template's
# skills as SKILL.md.tmpl so OpenCode's recursive skill scan does not register them globally.
set -euo pipefail
src="$(cd "$(dirname "$0")/template" && pwd)"
usage() { sed -n '5,11s/^# \{0,1\}//p' "$0" >&2; exit 2; }

tpl() { # project path -> template file, or fail
  case "$1" in /*|..|../*|*/../*|*/..) return 1 ;; esac
  if [ -f "$src/$1" ]; then echo "$src/$1"; elif [ -f "$src/$1.tmpl" ]; then echo "$src/$1.tmpl"; else return 1; fi
}
owned() { # list relay-owned project paths
  (cd "$src" && find . -type f) | sed 's#^\./##; s#\.tmpl$##' | sort \
    | grep -vxE 'AGENTS\.md|CLAUDE\.md|relay/STATUS\.md|(.*/)?\.gitkeep' || true
}
block() { # the AGENTS.md pointer block
  awk '/^This repo uses relay/{p=1} p{print} p&&/^Tools that read this file/{exit}' "$1" 2>/dev/null || true
}

case "${1:-}" in
  ""|-h|--help) usage ;;
  --show)
    f="$(tpl "${2:?usage: init.sh --show FILE}")" || { echo "no template file: $2" >&2; exit 1; }
    cat "$f" ;;
  --diff)
    dst="${2:?usage: init.sh --diff DIR}"; new=(); changed=(); same=0
    while IFS= read -r rel; do
      f="$(tpl "$rel")"
      if [ ! -e "$dst/$rel" ]; then new+=("$rel")
      elif cmp -s "$f" "$dst/$rel"; then same=$((same+1))
      else changed+=("$rel"); fi
    done < <(owned)
    want="$(block "$src/AGENTS.md")"; have="$(block "$dst/AGENTS.md")"
    for r in ${new[@]+"${new[@]}"}; do echo "new      $r"; done
    for r in ${changed[@]+"${changed[@]}"}; do echo "changed  $r"; done
    if [ -z "$have" ]; then echo "missing  AGENTS.md pointer block"
    elif [ "$have" != "$want" ]; then echo "changed  AGENTS.md pointer block"; fi
    echo "up to date: $same file(s)"
    for r in ${changed[@]+"${changed[@]}"}; do
      echo; echo "=== diff $r (project -> template)"
      diff -u --label "project/$r" --label "template/$r" "$dst/$r" "$(tpl "$r")" || true
    done
    for r in ${new[@]+"${new[@]}"}; do
      echo; echo "=== new $r"; cat "$(tpl "$r")"
    done
    if [ "$have" != "$want" ]; then
      echo; echo "=== template AGENTS.md pointer block"; echo "$want"
    fi ;;
  --apply)
    dst="${2:?usage: init.sh --apply DIR FILE...}"; shift 2
    [ $# -gt 0 ] || usage
    for rel in "$@"; do
      if ! owned | grep -qxF -- "$rel"; then echo "not relay-owned, skipped: $rel" >&2; continue; fi
      mkdir -p "$dst/$(dirname "$rel")"
      cp -p "$(tpl "$rel")" "$dst/$rel"
      echo "  = $rel"
    done ;;
  -*) usage ;;
  *)
    dst="$1"
    mkdir -p "$dst"
    added=0; skipped=0; merge=()
    while IFS= read -r -d '' f; do
      rel="${f#"$src"/}"; rel="${rel%.tmpl}"
      if [ -e "$dst/$rel" ]; then
        skipped=$((skipped+1))
        case "$rel" in AGENTS.md|.gitattributes) merge+=("$rel") ;; esac
        continue
      fi
      mkdir -p "$dst/$(dirname "$rel")"
      cp -p "$f" "$dst/$rel"
      echo "  + $rel"; added=$((added+1))
    done < <(find "$src" -type f -print0)
    echo "added $added, left $skipped existing file(s) alone"
    for rel in ${merge[@]+"${merge[@]}"}; do
      echo
      if [ "$rel" = AGENTS.md ]; then
        echo "=== merge AGENTS.md: it already existed. Template copy, for its pointer block and Project specifics:"
        cat "$src/AGENTS.md"
      else
        lines="$(grep -vxFf "$dst/.gitattributes" "$src/.gitattributes" || true)"
        if [ -n "$lines" ]; then
          echo "=== merge .gitattributes: it already existed. Template lines it lacks:"; echo "$lines"
        else
          echo "=== .gitattributes already has every template line"
        fi
      fi
    done ;;
esac
