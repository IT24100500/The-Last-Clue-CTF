#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run inside Ubuntu as root: sudo bash verify-reset.sh" >&2
  exit 1
fi

target=/opt/the-last-clue/stage03/hint.txt
echo "MEMBER 4 - SNAPSHOT RECOVERY (AFTER RESTORE)"
echo "============================================"
if [[ ! -r "$target" ]]; then
  echo "FAIL: cannot read the protected recovery probe as this account." >&2
  exit 1
fi
if grep -q 'MEMBER4-RESET-PROBE' "$target"; then
  echo "FAIL: the temporary challenge-file change remains."
  exit 1
else
  grep_status=$?
  if [[ "$grep_status" -ne 1 ]]; then
    echo "FAIL: unable to inspect the recovery probe (grep status $grep_status)." >&2
    exit "$grep_status"
  fi
fi
echo "PASS: temporary challenge-file change is gone."
sha256sum "$target"
stat -c '%A %U:%G %a %n' "$target" /tmp/note.py \
  /opt/the-last-clue/stage04/bella_note.txt \
  /opt/the-last-clue/stage06/telnet.pcap \
  /root/final_flag.txt /root/the-last-clue-answer-key.txt
systemctl is-active ssh
systemctl is-active the-last-clue-http.service
ip -br addr
http_status="$(curl -sS -o /dev/null -w '%{http_code}' http://192.168.56.103/robots.txt)"
[[ "$http_status" == 200 ]] || { echo "FAIL: HTTP status $http_status" >&2; exit 1; }
echo "PASS: host-only HTTP endpoint returned 200."

python3 -c '
import subprocess
program = ["runuser", "-u", "bella", "--", "/bin/bash", "/home/bella/catchme"]
for candidate, expected, label in (
    ("wrong-key\n", "ACCESS DENIED", "incorrect TLC-03 key is denied"),
    ("L45VENOK\n", "ACCESS ACCEPTED", "correct TLC-03 key is accepted"),
):
    result = subprocess.run(program, input=candidate, text=True, capture_output=True)
    if expected not in result.stdout + result.stderr:
        raise SystemExit(f"FAIL: {label}")
    print(f"PASS: {label}.")
'

echo "Recovery verified; intended Stage 3 solve behavior is restored."
