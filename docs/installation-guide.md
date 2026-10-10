# The Last Clue — Installation Guide

> **Project:** The Last Clue — VM-based Capture The Flag (CTF)  
> **Module:** IE3132 Penetration Testing — Assignment 02  
> **Focus:** CTF Platform & Architecture  
> **Status:** This is a deployment template. Replace example values with your actual configuration and verify every step before claiming the box works.

## Table of Contents

- [1. Overview](#1-overview)
- [2. Architecture](#2-architecture)
- [3. Prerequisites](#3-prerequisites)
- [4. Create the VirtualBox network](#4-create-the-virtualbox-network)
- [5. Create the Ubuntu CTF server VM](#5-create-the-ubuntu-ctf-server-vm)
- [6. Configure networking](#6-configure-networking)
- [7. Install and verify services](#7-install-and-verify-services)
- [8. Configure the Kali participant VM](#8-configure-the-kali-participant-vm)
- [9. Deploy challenge files](#9-deploy-challenge-files)
- [10. Verify connectivity](#10-verify-connectivity)
- [11. Flag validation](#11-flag-validation)
- [12. Reset and recovery](#12-reset-and-recovery)
- [13. Troubleshooting](#13-troubleshooting)
- [14. Pre-submission checklist](#14-pre-submission-checklist)
- [15. Safety and repository hygiene](#15-safety-and-repository-hygiene)

## 1. Overview

The Last Clue is a story-driven CTF involving three siblings: Levin, Bella, and Adam. The planned environment uses two VirtualBox virtual machines:

- **Ubuntu Server VM:** hosts Apache, SSH, challenge files, CTF accounts, and evidence.
- **Kali Linux VM:** participant environment for reconnaissance and challenge solving.

The six stages are:

1. **TLC-01 — The Father's First Trace**
2. **TLC-02 — Levin's Photograph**
3. **TLC-03 — Bella's Scripted Lock**
4. **TLC-04 — Bella's Ciphered Note**
5. **TLC-05 — Adam's Deleted Timeline**
6. **TLC-06 — The Last Transmission**

Stage 3 is a standalone Python challenge; it does **not** require Flask or an additional web server. The intended exposed Ubuntu services are Apache over TCP/80 and SSH over TCP/22. Do not publish real credentials, private keys, or actual flags in a public repository.

## 2. Architecture

```text
                    HOST COMPUTER
                 +-------------------+
                 |     VirtualBox    |
                 |                   |
                 |  +-------------+  |
                 |  | Kali Linux  |  |
                 |  | Participant |  |
                 |  +------+------+  |
                 |         |         |
                 |    Host-only LAN  |
                 |         |         |
                 |  +------v------+  |
                 |  | Ubuntu      |  |
                 |  | CTF Server  |  |
                 |  | Apache :80  |  |
                 |  | SSH    :22  |  |
                 |  | Challenge   |  |
                 |  | files/data  |  |
                 |  +-------------+  |
                 +-------------------+
```

Example addresses only; change these to match your actual lab:

| Component | Example address |
|---|---|
| Ubuntu CTF server | `192.168.56.10/24` |
| Kali participant | `192.168.56.20/24` |
| Host-only subnet | `192.168.56.0/24` |

Check for conflicts with existing host networks before using this subnet.

## 3. Prerequisites

- Oracle VirtualBox.
- Ubuntu Server ISO; a currently supported LTS release such as Ubuntu Server 24.04 LTS is recommended for a new build.
- A Kali Linux VM or official Kali installation image.
- Enough host RAM, CPU, and disk space to run both VMs.
- Challenge files and deployment scripts from this repository.

Suggested starting resources (adjust for your host):

| VM | RAM | CPU | Disk |
|---|---:|---:|---:|
| Ubuntu Server | 2 GB | 2 vCPUs | 20 GB |
| Kali Linux | 4 GB | 2 vCPUs | 30 GB |

These are suggestions, not measured requirements.

## 4. Create the VirtualBox network

1. Shut down both VMs.
2. Open VirtualBox's Host Network Manager (menu wording varies by version).
3. Create a Host-only network and record its name and subnet.
4. Configure both VMs to use that same Host-only network adapter.
5. Disable unnecessary adapters. Do not leave an unrestricted bridged adapter enabled.
6. If Internet access is temporarily required for updates, use a controlled method and disconnect it before the isolated demonstration.
7. Take a clean snapshot before deploying challenges.

Host-only networking helps keep the CTF off the public network. Verify the actual adapter configuration instead of relying only on its name.

## 5. Create the Ubuntu CTF server VM

1. Create a VirtualBox VM and attach the Ubuntu Server ISO.
2. Install Ubuntu Server and create a dedicated administrative account.
3. Set a clear hostname, for example `tlc-ubuntu` (example only).
4. While using controlled Internet access if needed, update packages:

```bash
sudo apt update
sudo apt upgrade
```

5. Shut down the VM, attach its network adapter to the Host-only network, then start it again.
6. Log in and take a baseline snapshot.

Keep the administrator account separate from the CTF participant accounts. Do not reuse personal passwords or keys.

## 6. Configure networking

Identify the actual network interface and current routes:

```bash
ip -br address
ip route
```

Ubuntu Server commonly uses Netplan, but interface names and configuration files vary. Back up the existing configuration before changing it, and consult current Ubuntu documentation. Do not copy a configuration that uses an interface name that does not exist on your VM.

Example addresses only:

- Ubuntu: `192.168.56.10/24`
- Kali: `192.168.56.20/24`

Avoid duplicate IP addresses and conflicts with existing networks.

## 7. Install and verify services

On Ubuntu, install Apache and OpenSSH:

```bash
sudo apt update
sudo apt install apache2 openssh-server
sudo systemctl enable --now apache2
sudo systemctl enable --now ssh
```

Verify services and listening ports:

```bash
sudo systemctl status apache2
sudo systemctl status ssh
sudo ss -tulpn
```

Intended exposed services:

- **TCP/80:** Apache HTTP
- **TCP/22:** OpenSSH

Verify the actual listening sockets and scan from Kali before claiming only the intended services are exposed.

### Firewall

Inspect current rules:

```bash
sudo ufw status verbose
```

For a dedicated isolated lab, the following is a simple example—not a universal production policy:

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw enable
sudo ufw status numbered
```

Enabling a firewall can interrupt remote access. Keep console access available and verify the resulting rules. For stricter isolation, limit rules to the Host-only subnet or interface. Do not apply these example rules blindly to a production machine.

### Apache landing page

Apache commonly uses `/var/www/html` as its document root. Check the active site configuration before deploying files. The intended Stage 1 path leads from the Apache site to `robots.txt`, then to the CTF-created `secret.txt` clue.

Do not place real secrets, administrator credentials, or private SSH keys in the web root. Use only CTF-created clues and credentials.

## 8. Configure the Kali participant VM

1. Create or import Kali Linux in VirtualBox.
2. Attach it to the same Host-only network as Ubuntu.
3. Start Kali and inspect its network configuration:

```bash
ip -br address
ip route
```

4. Confirm Kali has an address on the chosen subnet.
5. Install tools required by your implemented stages. Common examples:

```bash
sudo apt update
sudo apt install nmap curl openssh-client python3
```

Install additional tools, such as ExifTool or Wireshark, only if your implemented challenges need them.

## 9. Deploy challenge files

Use the actual files and scripts from your repository. Do not create empty placeholders and claim a stage is complete.

Suggested server-side organization (adapt to your implementation):

```text
/opt/the-last-clue/
├── stages/
│   ├── TLC-01/
│   ├── TLC-02/
│   ├── TLC-03/
│   ├── TLC-04/
│   ├── TLC-05/
│   └── TLC-06/
├── evidence/
└── scripts/
```

Create a dedicated project directory and assign ownership and permissions deliberately. Files that should not be visible to participants must not be world-readable or placed in Apache's document root.

### Account and stage reminders

- Create only the CTF-specific accounts required by your implementation, such as `levin`, `bella`, and `adam`.
- Use CTF-only credentials and keys. Never commit private SSH keys or passwords to GitHub.
- Levin-to-Bella is a **horizontal user transition**, not vertical privilege escalation.
- TLC-03 is a standalone Python challenge, not a Flask application.
- TLC-05 should use the actual forensic artifacts and PCAP created for the challenge.
- TLC-06 may use a narrowly scoped, intentionally configured CTF sudo privilege. Do not grant broad passwordless sudo as a shortcut.
- Keep instructor-only answers and real flag values out of a public repository where appropriate.

## 10. Verify connectivity

Replace `192.168.56.10` with the actual Ubuntu IP.

```bash
ping -c 4 192.168.56.10
nmap -sV -p 22,80 192.168.56.10
curl -I http://192.168.56.10/
```

Test SSH only with a configured CTF account and its CTF credentials:

```bash
ssh levin@192.168.56.10
```

Record the real results. A failed ping alone does not prove the server is unavailable; check the IP address, route, firewall, and TCP connectivity.

## 11. Flag validation

Document the validation mechanism actually implemented. The assignment permits a platform-based method or documented manual validation.

Record:

- Expected flag format (for example, `CTF{...}`).
- Where/how participants submit or verify a flag.
- Expected behavior for valid and invalid submissions.
- How duplicate submissions are handled, if applicable.
- Test cases and actual results.

Do not claim a validation script exists unless it is included and works.

## 12. Reset and recovery

Choose and test a repeatable reset approach:

1. **VirtualBox snapshot:** restore a known clean VM state.
2. **Reset script:** restore challenge files, account settings, permissions, and evidence.
3. **Rebuild procedure:** recreate the environment using documented steps.

A snapshot does not automatically reset every VM. Document whether both VMs must be restored and whether network settings are preserved.

After reset, verify:

- Apache and SSH are running.
- Expected ports are reachable from Kali.
- The first clue is present.
- Challenge files and permissions are restored.
- Flags and evidence are in their intended initial state.
- Previous participant changes are removed.

Review a reset script before running it and back up important work.

## 13. Troubleshooting

| Problem | Checks |
|---|---|
| Kali cannot reach Ubuntu | Check VM adapters, Host-only network, IP addresses, subnet masks, and firewall. |
| Apache unavailable | Check `systemctl status apache2`, listening sockets, document-root permissions, and firewall rules. |
| SSH unavailable | Check `systemctl status ssh`, listening sockets, account configuration, and firewall rules. |
| Nmap finds unexpected ports | Inspect `sudo ss -tulpn`, identify processes, and stop or restrict unnecessary services. |
| SSH key authentication fails | Check username, public key placement, ownership, and permissions. Never upload the private key. |
| Clue is missing | Check deployed path, file permissions, and whether stage files were copied. |
| Reset breaks the box | Restore a clean snapshot or follow the rebuild procedure, then update and retest the reset instructions. |

## 14. Pre-submission checklist

- [ ] Both VMs boot and their network configuration is documented.
- [ ] The CTF server is isolated as intended.
- [ ] Apache and SSH are running and verified.
- [ ] Only intended services are exposed on the lab network.
- [ ] All six stages have been implemented and solved along the intended path.
- [ ] Flag validation has been tested.
- [ ] Reset/recovery has been tested.
- [ ] At least one original platform-related script is included and explained by the responsible member.
- [ ] Real screenshots and test results are saved.
- [ ] README and this guide match the actual implementation.
- [ ] Credentials, private keys, and unintended secrets are excluded from Git.
- [ ] Design changes from Assignment 01 are documented and technically justified.

## 15. Safety and repository hygiene

This project is for authorized educational use in a controlled lab. Use only systems, accounts, evidence, and configurations created for or explicitly authorized for the CTF. Keep the lab off public and institutional networks, and do not use real credentials.

Before committing:

```bash
git status
git diff --check
```

Review staged files for secrets, private keys, passwords, and instructor-only answer files. If a secret was committed previously, removing it from the latest commit may not be enough; rotate it and follow the repository's secret-removal procedure.

---

## Implementation record

Complete this section with verified details before submission:

- **Ubuntu version:** `REPLACE_WITH_VERIFIED_VERSION`
- **Kali version:** `REPLACE_WITH_VERIFIED_VERSION`
- **VirtualBox version:** `REPLACE_WITH_VERIFIED_VERSION`
- **Ubuntu Host-only IP:** `REPLACE_WITH_ACTUAL_IP`
- **Kali Host-only IP:** `REPLACE_WITH_ACTUAL_IP`
- **Actual exposed ports:** `REPLACE_WITH_VERIFIED_RESULTS`
- **Flag validation method:** `REPLACE_WITH_IMPLEMENTED_METHOD`
- **Reset/recovery method:** `REPLACE_WITH_TESTED_METHOD`
- **Last end-to-end test date:** `REPLACE_WITH_DATE`
- **Known limitations:** `DOCUMENT_ANY_UNRESOLVED_ISSUES`

> **Accuracy note:** This document is a setup template until the commands, challenge stages, validation, isolation, and reset procedure have been run and verified in the real environment.
