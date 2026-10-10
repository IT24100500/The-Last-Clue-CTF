#!/usr/bin/env bash
# The Last Clue — Ubuntu CTF server bootstrap
# Review this script before running. Run only on the dedicated CTF Ubuntu VM.
# It installs base services; it does NOT deploy all six challenge stages.

set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo bash setup.sh"
  exit 1
fi

echo "[1/4] Updating package index..."
apt-get update

echo "[2/4] Installing base packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apache2 \
  openssh-server \
  curl \
  python3 \
  ufw

echo "[3/4] Enabling intended services..."
systemctl enable --now apache2
systemctl enable --now ssh

echo "[4/4] Reporting service status..."
systemctl --no-pager --full status apache2 || true
systemctl --no-pager --full status ssh || true

echo
echo "Base setup completed."
echo "Next: configure the Host-only network, review firewall policy,"
echo "deploy the actual challenge files, then run verify-services.sh."
echo "This script does not configure static IPs, create CTF users, install flags,"
echo "or implement the challenge stages."
