#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run inside Ubuntu as root: sudo bash capture-access-control.sh" >&2
  exit 1
fi

echo "MEMBER 4 — ACCESS CONTROL PROOF"
echo "==============================="
echo "Attempting to read TLC-04 evidence as Levin (expected denial):"
if denial="$(runuser -u levin -- cat /opt/the-last-clue/stage04/bella_note.txt 2>&1)"; then
  echo "FAIL: Levin unexpectedly read TLC-04 evidence."
  exit 1
else
  printf '%s\n' "$denial"
fi
echo
echo "Permissions on the protected path:"
namei -l /opt/the-last-clue/stage04/bella_note.txt
stat -c '%A %U:%G %a %n' /opt/the-last-clue/stage04/bella_note.txt
echo
echo "Administrator-only final flag:"
stat -c '%A %U:%G %a %n' /root/final_flag.txt
stat -c '%A %U:%G %a %n' /root/the-last-clue-answer-key.txt
echo
echo "Proof complete: early-stage account is denied; evidence and answers stay private."
