#!/usr/bin/env bash
# The Last Clue — example firewall configuration for a dedicated CTF VM.
# Review before running. UFW rules may affect remote access.
# This script allows TCP/22 and TCP/80 from a configured lab subnet.
# Set LAB_SUBNET to your actual Host-only subnet before execution.

set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo LAB_SUBNET=192.168.56.0/24 bash configure-firewall.sh"
  exit 1
fi

LAB_SUBNET="${LAB_SUBNET:-}"
if [[ -z "${LAB_SUBNET}" ]]; then
  echo "ERROR: Set LAB_SUBNET to your actual Host-only subnet."
  echo "Example only: sudo LAB_SUBNET=192.168.56.0/24 bash configure-firewall.sh"
  exit 2
fi

echo "This will configure UFW on this dedicated CTF VM."
echo "Allowed from ${LAB_SUBNET}: TCP/22 (SSH) and TCP/80 (HTTP)."
echo "Ensure you have VirtualBox console access before continuing."
read -r -p "Apply these rules? Type APPLY to continue: " confirm
if [[ "${confirm}" != "APPLY" ]]; then
  echo "Cancelled."
  exit 0
fi

apt-get update
apt-get install -y ufw

# Set default policy and clear existing UFW rules only after explicit confirmation.
read -r -p "Reset existing UFW rules on this VM? Type RESET to confirm: " reset_confirm
if [[ "${reset_confirm}" == "RESET" ]]; then
  ufw --force reset
else
  echo "Existing UFW rules were not reset; continuing by adding the requested rules."
fi

ufw default deny incoming
ufw default allow outgoing
ufw allow from "${LAB_SUBNET}" to any port 22 proto tcp
ufw allow from "${LAB_SUBNET}" to any port 80 proto tcp

ufw --force enable
ufw status verbose

echo
echo "Review the output and test connectivity from Kali."
echo "If your real design needs other management paths, document and configure them deliberately."
