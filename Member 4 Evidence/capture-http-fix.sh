#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run inside Ubuntu as root: sudo bash capture-http-fix.sh" >&2
  exit 1
fi

lab_ip="$(ip -4 -o addr show dev enp0s8 | awk 'NR == 1 {split($4, a, "/"); print a[1]}')"
[[ -n "$lab_ip" ]] || { echo "Host-only IPv4 address not found." >&2; exit 1; }

echo "MEMBER 4 — HTTP PERMISSION DEFECT / FIX"
echo "======================================="
chmod 0700 /var/www/html
before="$(curl -sS -o /dev/null -w '%{http_code}' "http://${lab_ip}/robots.txt" || true)"
chmod 0755 /var/www/html
systemctl restart the-last-clue-http.service
after=""
for attempt in {1..20}; do
  after="$(curl -sS -o /dev/null -w '%{http_code}' "http://${lab_ip}/robots.txt" 2>/dev/null || true)"
  [[ "$after" == 200 ]] && break
  sleep 0.25
done
printf 'Before directory-permission fix: HTTP %s (expected 404)\n' "$before"
printf 'After chmod 0755 and service restart: HTTP %s (expected 200)\n' "$after"
stat -c '%A %U:%G %a %n' /var/www /var/www/html /var/www/html/robots.txt
[[ "$before" == 404 && "$after" == 200 ]] || {
  echo "The expected before/after result was not reproduced." >&2
  exit 1
}
echo "PASS: the restrictive web-root traversal permission caused the failure; 0755 restored service."
