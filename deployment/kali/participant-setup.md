# Kali Participant VM Setup

> This guide configures the participant VM for the isolated **The Last Clue** CTF. Example IPs are placeholders. Use only the authorized lab network.

## 1. Requirements

- VirtualBox installed on the host.
- Kali Linux VM created or imported from an official source.
- The VM is attached to the same VirtualBox **Host-only network** as the Ubuntu CTF server.
- The actual Ubuntu server IP is recorded by the project team.

## 2. Configure the VirtualBox adapter

1. Shut down the Kali VM.
2. Open **Settings → Network**.
3. Enable the adapter used for the lab.
4. Select **Host-only Adapter** (wording may vary by VirtualBox version).
5. Choose the same Host-only network as the Ubuntu server.
6. Disable unnecessary bridged or public-facing adapters for the CTF demonstration.
7. Start Kali.

## 3. Inspect network settings

Run:

```bash
ip -br address
ip route
```

Example values only:

- Ubuntu CTF server: `192.168.56.10`
- Kali participant VM: `192.168.56.20`
- Example subnet: `192.168.56.0/24`

Replace these with your actual values. Do not assign an address that conflicts with another device. If the Host-only network uses DHCP, inspect the assigned address before setting a static address.

## 4. Install basic participant tools

Update Kali when controlled Internet access is available, then install the basic tools used for connectivity checks and the challenge flow:

```bash
sudo apt update
sudo apt install -y nmap curl openssh-client python3
```

Install additional tools only if the implemented stages require them. For example, ExifTool may be useful for the photograph metadata challenge, and Wireshark or `tshark` may be useful for PCAP analysis.

```bash
sudo apt install -y libimage-exiftool-perl wireshark
```

Package names or prompts can vary by Kali release. Follow your lab's approved setup policy.

## 5. Verify the Ubuntu server

Replace the example address with the actual Ubuntu IP:

```bash
ping -c 4 192.168.56.10
nmap -sV -p 22,80 192.168.56.10
curl -I http://192.168.56.10/
```

A failed ping alone does not prove the server is unreachable. Check adapter settings, IP addresses, routes, and firewall rules.

Expected design services:

- TCP/80 — Apache HTTP
- TCP/22 — OpenSSH

Compare results with the real server configuration. Investigate any unexpected open ports.

## 6. Test SSH with authorized CTF credentials

Use only the CTF-specific account and credentials issued by your project:

```bash
ssh levin@192.168.56.10
```

Replace the username and IP if your implemented configuration differs. Never place passwords or private keys in this repository.

## 7. Participant tool mapping

| Challenge | Possible tool | Purpose |
|---|---|---|
| TLC-01 — The Father's First Trace | Browser, `curl` | Inspect the web clue |
| TLC-02 — Levin's Photograph | ExifTool | Inspect image metadata, if used by the implementation |
| TLC-03 — Bella's Scripted Lock | Python 3 | Analyze and solve the standalone programming challenge |
| TLC-04 — Bella's Ciphered Note | Python or suitable cryptography utilities | Analyze the implemented cipher |
| TLC-05 — Adam's Deleted Timeline | Wireshark / `tshark` | Investigate supplied network evidence |
| TLC-06 — The Last Transmission | SSH and authorized lab tools | Correlate evidence and complete the intended final challenge |

This table describes intended tool categories. Use the actual tools required by the implemented challenges.

## 8. Safety

- Test only against the designated CTF server.
- Keep the lab isolated from public and institutional networks.
- Do not use real credentials.
- Do not scan systems outside the authorized lab.
- Record actual test results; do not claim a test passed unless you ran it.
