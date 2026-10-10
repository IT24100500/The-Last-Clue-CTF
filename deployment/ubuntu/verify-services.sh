#!/usr/bin/env bash
# The Last Clue — Ubuntu service and deployment verification
# This script reports state; it does not make changes or prove every challenge is solvable.

set -u

echo "=== Host ==="
hostnamectl --static 2>/dev/null || hostname
echo
echo "=== IP addresses ==="
ip -br address
echo
echo "=== Routes ==="
ip route
echo
echo "=== Apache ==="
if systemctl is-active --quiet apache2; then
  echo "PASS: apache2 is active"
else
  echo "FAIL: apache2 is not active"
fi
systemctl --no-pager --full status apache2 2>/dev/null || true
echo
echo "=== SSH ==="
if systemctl is-active --quiet ssh; then
  echo "PASS: ssh is active"
else
  echo "FAIL: ssh is not active"
fi
systemctl --no-pager --full status ssh 2>/dev/null || true
echo
echo "=== Listening TCP sockets ==="
sudo ss -ltnp 2>/dev/null || ss -ltn
echo
echo "=== Firewall ==="
if command -v ufw >/dev/null 2>&1; then
  sudo ufw status verbose 2>/dev/null || ufw status verbose
else
  echo "UFW is not installed."
fi
echo
echo "=== HTTP local response ==="
if command -v curl >/dev/null 2>&1; then
  curl --max-time 5 -sS -I http://127.0.0.1/ || true
else
  echo "curl is not installed."
fi
echo
echo "Reminder: verify reachability from Kali and test all six stages separately."
