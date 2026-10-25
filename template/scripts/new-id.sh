#!/usr/bin/env bash
# Print a fresh ticket or decision id: today's date plus three random base36 characters, e.g. 2026-10-25-k7q.
# Two clones minting on the same day collide only if they draw the same three characters; status.sh
# refuses to write the board if that happens. Rerolls while the suffix is already used here, so the
# suffix alone (`pickup k7q`) names one file.
set -euo pipefail
cd "$(dirname "$0")/.."

chars=abcdefghijklmnopqrstuvwxyz0123456789
for _ in 1 2 3 4 5 6 7 8 9 10; do
  s=""
  for _ in 1 2 3; do s+=${chars:RANDOM%36:1}; done
  if ! compgen -G "relay/tickets/????-??-??-$s-*.md" >/dev/null && ! compgen -G "relay/decisions/????-??-??-$s-*.md" >/dev/null; then
    echo "$(date +%Y-%m-%d)-$s"
    exit 0
  fi
done
echo "new-id.sh: no free suffix after 10 tries" >&2
exit 1
