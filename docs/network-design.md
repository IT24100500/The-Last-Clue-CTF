# The Last Clue — Network Design

> **Status:** Design and configuration record template. Replace examples with the values from your real VirtualBox environment and verify all claims before submission.

## 1. Purpose

The network is intended to isolate the CTF server from public and institutional systems while allowing the Kali participant VM to reach the Ubuntu CTF server.

## 2. Logical design

```text
+------------------------- VirtualBox Host --------------------------+
|                                                                    |
|  +----------------------+       Host-only network                  |
|  | Kali Linux VM        |----------------------------------+       |
|  | Participant / tester|                                  |       |
|  +----------------------+                                  |       |
|                                                            |       |
|  +----------------------+                                  |       |
|  | Ubuntu Server VM     |<---------------------------------+       |
|  | Apache TCP/80        |                                          |
|  | SSH TCP/22           |                                          |
|  +----------------------+                                          |
+--------------------------------------------------------------------+
```

## 3. Address plan

The following values are examples only.

| Component | Example value | Actual value |
|---|---|---|
| Host-only subnet | `192.168.56.0/24` | `RECORD_ACTUAL_SUBNET` |
| Ubuntu server | `192.168.56.10/24` | `RECORD_ACTUAL_UBUNTU_IP` |
| Kali participant | `192.168.56.20/24` | `RECORD_ACTUAL_KALI_IP` |
| Ubuntu adapter name | `RECORD_AFTER_CHECKING` | `RECORD_ACTUAL_ADAPTER` |
| VirtualBox network name | `Host-only Network` | `RECORD_ACTUAL_NETWORK_NAME` |

Check that the chosen subnet does not overlap with a host LAN, VPN, or another virtual network.

## 4. Intended services

| Service | Protocol/port | Purpose | Verification |
|---|---|---|---|
| Apache HTTP | TCP/80 | Stage 1 web clue | Verify with `systemctl`, `ss`, and a Kali request |
| OpenSSH | TCP/22 | CTF account access | Verify with `systemctl`, `ss`, and an authorized SSH test |

The assignment design expects these services. Verify the real machine for additional listening ports rather than assuming no others exist.

## 5. Configuration and verification

On Ubuntu:

```bash
ip -br address
ip route
sudo ss -tulpn
sudo ufw status verbose
```

On Kali, substitute the actual Ubuntu address:

```bash
ping -c 4 192.168.56.10
nmap -sV -p 22,80 192.168.56.10
curl -I http://192.168.56.10/
```

A failed ping does not by itself prove the host is unavailable. Check IP configuration, routes, firewall rules, and TCP connectivity.

## 6. Isolation controls

- Attach both VMs to the same VirtualBox Host-only network for the CTF demonstration.
- Disable unnecessary adapters, especially unrestricted bridged networking.
- If Internet access is temporarily needed for updates, disconnect it before the isolated test.
- Restrict firewall rules to the lab network/interface where practical.
- Use only CTF-created accounts, credentials, files, and intentionally vulnerable configurations.
- Do not test against public or institutional systems.

## 7. Firewall notes

Review current rules before making changes:

```bash
sudo ufw status verbose
```

A basic example for a dedicated lab is:

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw status numbered
```

If enabling UFW, make sure console access is available and verify the resulting rules. This example is not a complete production firewall policy; consider restricting access to the Host-only subnet.

## 8. Record the real configuration

Complete before submitting:

- VirtualBox version: `REPLACE_WITH_VERIFIED_VERSION`
- Host-only network name: `REPLACE_WITH_ACTUAL_NAME`
- Host-only subnet: `REPLACE_WITH_ACTUAL_SUBNET`
- Ubuntu IP/interface: `REPLACE_WITH_ACTUAL_VALUES`
- Kali IP/interface: `REPLACE_WITH_ACTUAL_VALUES`
- Actual listening ports: `REPLACE_WITH_VERIFIED_RESULTS`
- Firewall rules: `REPLACE_WITH_VERIFIED_SUMMARY`
- Date verified: `REPLACE_WITH_DATE`
- Known limitations: `DOCUMENT_ANY_ISSUES`
