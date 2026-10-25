#!/usr/bin/env bash
# Install /relay-init as an OpenCode command. OpenCode 1 finds the skill in ~/.claude/skills/ but its TUI lists skills
# only under /skills, never as their own slash command; a command file is what makes /relay-init appear.
# Usage: bash opencode-command.sh [--check]
# Copies opencode/relay-init.md from this bundle to ${XDG_CONFIG_HOME:-~/.config}/opencode/commands/relay-init.md.
# Writes only when the file is missing or is an older copy of this bundle's command (found in the clone's git history).
# A file that differs any other way is someone's own edit: shows the diff and exits 1 without touching it.
# --check writes nothing and prints one state: current, missing, stale or conflict (exit 0 except on bad usage).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
rel=opencode/relay-init.md
src="$here/$rel"
dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/commands"
dest="$dir/relay-init.md"
check=0
case "${1:-}" in
  "") ;;
  --check) check=1 ;;
  *) echo "usage: opencode-command.sh [--check]" >&2; exit 2 ;;
esac
[ -f "$src" ] || { echo "opencode-command.sh: missing $src" >&2; exit 1; }

older() { # dest equals some earlier committed version of the command
  [ -e "$here/.git" ] || return 1
  local c
  for c in $(git -C "$here" log --format=%H -- "$rel" 2>/dev/null); do
    git -C "$here" show "$c:$rel" 2>/dev/null | cmp -s - "$dest" && return 0
  done
  return 1
}

if [ ! -e "$dest" ]; then state=missing
elif cmp -s "$src" "$dest"; then state=current
elif older; then state=stale
else state=conflict
fi
# OpenCode also reads the singular command/ folder; a relay-init.md there would compete with ours.
other="$(dirname "$dir")/command/relay-init.md"

if [ "$check" = 1 ]; then
  echo "$state"
  [ ! -e "$other" ] || echo "note: $other also exists" >&2
  exit 0
fi
case "$state" in
  current) echo "OpenCode command up to date: $dest" ;;
  missing|stale)
    mkdir -p "$dir"
    cp "$src" "$dest"
    [ "$state" = missing ] && echo "installed OpenCode command: $dest" || echo "updated OpenCode command: $dest" ;;
  conflict)
    echo "refusing: $dest exists and is not a relay copy (a local edit?). Left as is:" >&2
    diff -u "$dest" "$src" >&2 || true
    echo "To use relay's version, move that file away and rerun this script." >&2
    exit 1 ;;
esac
[ ! -e "$other" ] || echo "warning: $other also exists; remove it or it may shadow this command" >&2
echo "Fully quit and restart OpenCode to load it."
