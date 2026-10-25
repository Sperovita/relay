#!/usr/bin/env bash
# Drop relay into a project. Never overwrites existing files.
# Usage: ./init.sh /path/to/project
# A trailing .tmpl is dropped on copy: the installed /relay-init bundle stores the template's
# skills as SKILL.md.tmpl so OpenCode's recursive skill scan does not register them globally.
set -euo pipefail
src="$(cd "$(dirname "$0")/template" && pwd)"
dst="${1:?usage: init.sh /path/to/project}"
mkdir -p "$dst"
added=0; skipped=0
while IFS= read -r -d '' f; do
  rel="${f#"$src"/}"; rel="${rel%.tmpl}"
  if [ -e "$dst/$rel" ]; then
    skipped=$((skipped+1)); continue
  fi
  mkdir -p "$dst/$(dirname "$rel")"
  cp -p "$f" "$dst/$rel"
  echo "  + $rel"; added=$((added+1))
done < <(find "$src" -type f -print0)
echo "added $added, left $skipped existing file(s) alone"
echo "next: edit $dst/AGENTS.md project specifics, then commit."
