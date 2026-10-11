#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run inside Ubuntu as root: sudo bash reset-probe.sh" >&2
  exit 1
fi

target=/opt/the-last-clue/stage03/hint.txt
sed -i '/MEMBER4-RESET-PROBE/d' "$target"
echo "MEMBER 4 — RESET TEST (BEFORE RESTORE)"
echo "======================================"
echo "Clean baseline hash:"
sha256sum "$target"
printf '\nMEMBER4-RESET-PROBE\n' >>"$target"
echo
echo "Controlled challenge-file mutation:"
grep -n 'MEMBER4-RESET-PROBE' "$target"
sha256sum "$target"
