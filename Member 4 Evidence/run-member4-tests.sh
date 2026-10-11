#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run inside the Ubuntu VM as root: sudo bash run-member4-tests.sh" >&2
  exit 1
fi

pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1" >&2; exit 1; }

printf '%s\n' 'THE LAST CLUE — MEMBER 4 INTEGRATION TESTS' '============================================'
ip -br addr
printf '\n'
printf 'HTTP/SSH listeners:\n'
ss -lnt | awk 'NR == 1 || /:22[[:space:]]|:80[[:space:]]/'
systemctl is-active --quiet ssh && systemctl is-active --quiet the-last-clue-http.service \
  || fail 'Required SSH/HTTP services are not active'

lab_ip="$(ip -4 -o addr show dev enp0s8 | awk 'NR == 1 {split($4, a, "/"); print a[1]}')"
[[ -n "$lab_ip" ]] || fail 'No participant address on enp0s8'
robots="$(curl -fsS "http://${lab_ip}/robots.txt")"
record="$(curl -fsS "http://${lab_ip}/family/records.b64" | tail -n 1 | base64 -d)"
grep -Fq '/family/' <<<"$robots" || fail 'TLC-01 robots clue is missing'
grep -Fq 'CTF{TLC-01-FATHERS-TRACE}' <<<"$record" || fail 'TLC-01 clue/flag is invalid'
pass 'TLC-01 HTTP clue decodes to its expected result'

python3 - <<'PY'
import base64
import pathlib
import re
import struct
import zlib

root = pathlib.Path("/opt/the-last-clue")
png = (root / "stage02/levin.png").read_bytes()
assert png.startswith(b"\x89PNG\r\n\x1a\n")
offset = 8
metadata = None
while offset < len(png):
    length = struct.unpack(">I", png[offset:offset + 4])[0]
    kind = png[offset + 4:offset + 8]
    body = png[offset + 8:offset + 8 + length]
    if kind == b"tEXt" and body.startswith(b"Comment\0"):
        metadata = base64.b64decode(body.split(b"\0", 1)[1]).decode()
        break
    offset += length + 12
assert metadata and "/usr/share" in metadata and "/var/local" in metadata
clue = pathlib.Path("/usr/share/clue.py").read_text()
assert "base64.b64decode" in clue
print("PASS  TLC-02 PNG metadata decodes to the expected search locations")

note = base64.b64decode((root / "stage04/bella_note.txt").read_text().strip()).decode()
plain = "".join(
    chr((ord(c) - ord("A") - 3) % 26 + ord("A")) if "A" <= c <= "Z"
    else chr((ord(c) - ord("a") - 3) % 26 + ord("a")) if "a" <= c <= "z"
    else c
    for c in note
)
assert "ADAM-PCAP-17" in plain and "CTF{TLC-04-CIPHERED-NOTE}" in plain
print("PASS  TLC-04 Base64/Caesar clue decodes to the Adam evidence identifier")

logs = pathlib.Path("/media/log")
assert "20:14" in (logs / "timeline.txt").read_text()
assert "20:14" in (logs / "access.log").read_text()
hidden = logs / ".deleted_transmission.txt"
assert hidden.is_file() and "20:14:00-20:15:00" in hidden.read_text()
assert "CTF{TLC-05-DELETED-TIMELINE}" in hidden.read_text()
print("PASS  TLC-05 hidden evidence and logs agree on the PCAP time window")

capture = (root / "stage06/telnet.pcap").read_bytes()
assert capture[:4] == b"\xd4\xc3\xb2\xa1", "Unexpected PCAP magic"
offset = 24
frames = []
while offset < len(capture):
    seconds, micros, captured, original = struct.unpack("<IIII", capture[offset:offset + 16])
    offset += 16
    frame = capture[offset:offset + captured]
    assert len(frame) == captured and captured == original
    frames.append((seconds, frame))
    offset += captured
assert len(frames) == 5, f"Expected five packets, got {len(frames)}"
tcp_frames = []
for seconds, frame in frames:
    assert 10 <= seconds % 86400 - (20 * 3600 + 14 * 60) <= 20
    if len(frame) < 54 or frame[12:14] != b"\x08\x00" or frame[23] != 6:
        continue
    ip_header_len = (frame[14] & 0x0f) * 4
    tcp_offset = 14 + ip_header_len
    src_port, dst_port = struct.unpack(">HH", frame[tcp_offset:tcp_offset + 4])
    if src_port == 23 or dst_port == 23:
        tcp_frames.append(frame)
stream = b"".join(tcp_frames)
assert len(tcp_frames) >= 2
assert b"CTF{TLC-06-LAST-TRANSMISSION}" in stream
match = re.search(rb"Password: ([0-9a-f]{32})", stream)
assert match, "The PCAP should contain only the generated disposable lab credential"
credential = match.group(1)
for history in pathlib.Path("/home").glob("*/.bash_history"):
    assert credential not in history.read_bytes(), f"Lab credential found in {history}"
root_history = pathlib.Path("/root/.bash_history")
if root_history.exists():
    assert credential not in root_history.read_bytes()
print("PASS  TLC-06 PCAP has the expected timed Telnet stream and final result")
print("PASS  Generated lab credential is absent from shell history")
PY

python3 - <<'PY'
import subprocess

program = ["runuser", "-u", "bella", "--", "/bin/bash", "/home/bella/catchme"]
for candidate, expected, label in (
    ("wrong-key\n", "ACCESS DENIED", "invalid key is denied"),
    ("L45VENOK\n", "ACCESS ACCEPTED", "valid key is accepted"),
):
    result = subprocess.run(program, input=candidate, text=True, capture_output=True)
    output = result.stdout + result.stderr
    if expected not in output:
        raise SystemExit(f"FAIL  TLC-03 {label} (exit={result.returncode})")
    print(f"PASS  TLC-03 {label}")
PY

adam_uid="$(id -u adam)"
if runuser -u bella -- test -w /tmp/note.py \
  && visudo -cf /etc/sudoers.d/the-last-clue-bella >/dev/null 2>&1; then
  note_backup="$(mktemp)"
  cp -p /tmp/note.py "$note_backup"
  restore_note() {
    cp -p "$note_backup" /tmp/note.py
    chown bella:bella /tmp/note.py
    rm -f "$note_backup"
  }
  trap restore_note EXIT
  runuser -u bella -- python3 -c "open('/tmp/note.py', 'w').write('import os\\nprint(os.geteuid())\\n')"
  escalated_uid="$(runuser -u bella -- sudo -n -u adam /usr/bin/python3 /tmp/note.py)"
  [[ "$escalated_uid" == "$adam_uid" ]] || fail 'TLC-04 did not run as Adam'
  restore_note
  trap - EXIT
  pass 'TLC-04 Bella-to-Adam controlled sudo path works; original note restored'
else
  fail 'TLC-04 writable note or sudo rule is missing'
fi

if runuser -u levin -- test ! -r /opt/the-last-clue/stage04/bella_note.txt \
  && ! runuser -u levin -- cat /root/final_flag.txt >/dev/null 2>&1; then
  pass 'Earlier-stage user cannot read protected later-stage evidence or final flag'
else
  fail 'An earlier-stage user can read protected evidence'
fi
[[ "$(stat -c '%a' /root/the-last-clue-answer-key.txt)" == 600 ]] \
  || fail 'Administrator answer key permissions are not 0600'
[[ "$(stat -c '%a' /root/final_flag.txt)" == 600 ]] \
  || fail 'Final flag permissions are not 0600'
pass 'Administrator answer key and final flag are root-only (0600)'

if command -v tlc-validate >/dev/null 2>&1; then
  pass 'A flag-validator command is installed'
else
  printf '%s\n' 'NOT IMPLEMENTED  Standalone flag-submission validator'
fi
if git -C /opt/the-last-clue rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C /opt/the-last-clue log --oneline --all --decorate -5
else
  printf '%s\n' 'NOT AVAILABLE  No Git history for the deployed challenge directory'
fi

printf '\n%s\n' 'Integration tests complete. Snapshot recovery is tested separately.'
