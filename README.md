# The Last Clue — Architecture & Design

<p align="center">
  <strong>A Story-Driven, VM-Based Capture The Flag (CTF)</strong><br>
  <em>IE3132 Penetration Testing · Assignment 02</em>
</p>

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-VirtualBox-blue">
  <img alt="Environment" src="https://img.shields.io/badge/Environment-Ubuntu%20%2B%20Kali-orange">
  <img alt="Network" src="https://img.shields.io/badge/Network-Host--Only-green">
  <img alt="Stages" src="https://img.shields.io/badge/Challenges-6-purple">
</p>

> **Document scope:** This README describes the intended architecture and challenge design of *The Last Clue*. Example IP addresses are illustrative. Update the document to match the actual implementation before claiming that any component has been deployed or tested.

---

## Table of Contents

- [1. Project Overview](#1-project-overview)
- [2. Scenario](#2-scenario)
- [3. Design Goals](#3-design-goals)
- [4. System Architecture](#4-system-architecture)
- [5. Network Design](#5-network-design)
- [6. Challenge Flow](#6-challenge-flow)
- [7. Challenge Design](#7-challenge-design)
- [8. Security Design](#8-security-design)
- [9. Technology Stack](#9-technology-stack)
- [10. Deployment and Validation Boundaries](#10-deployment-and-validation-boundaries)
- [11. Repository Layout](#11-repository-layout)
- [12. Design Status](#12-design-status)

## 1. Project Overview

**The Last Clue** is a story-driven Capture The Flag (CTF) project designed to provide hands-on practice in penetration testing and cybersecurity investigation. Participants follow a sequence of digital clues across six stages, progressing from basic reconnaissance to an integrated final challenge.

The intended platform uses two virtual machines in Oracle VirtualBox:

- **Ubuntu Server VM:** CTF server hosting the Apache entry point, SSH service, challenge resources, CTF accounts, and digital evidence.
- **Kali Linux VM:** participant environment for reconnaissance, analysis, scripting, and authorized challenge interaction.

The design uses a **Host-only virtual network** to keep the lab separate from public and institutional networks. Docker and containers are not part of this design.

## 2. Scenario

Three siblings—**Levin, Bella, and Adam**—are connected to a family mystery involving their mother's unexplained death. Their father's clues lead the participant through digital artifacts, user accounts, programming, cryptography, and forensic evidence.

The participant begins by investigating a web server and follows the clues from Levin to Bella and then Adam. The final stage combines evidence gathered earlier and ends with an intentionally configured, authorized privilege-escalation challenge inside the CTF.

## 3. Design Goals

- Provide six connected and progressively more difficult challenges.
- Cover multiple cybersecurity domains through practical tasks.
- Encourage information gathering and justified tool selection.
- Include at least one programming or solver task.
- Keep all testing within a dedicated, isolated lab.
- Provide a repeatable deployment, verification, and reset process.
- Ensure each stage follows an intended solution path rather than a trivial shortcut.

## 4. System Architecture

```text
                         PHYSICAL HOST
                 +--------------------------------+
                 |            VirtualBox          |
                 |                                |
                 |  +--------------------------+  |
                 |  | KALI LINUX VM            |  |
                 |  | Participant / Tester     |  |
                 |  |                          |  |
                 |  | Nmap, Browser, SSH       |  |
                 |  | Python, ExifTool,        |  |
                 |  | forensic analysis tools  |  |
                 |  +------------+-------------+  |
                 |               |                |
                 |               |                |
                 |        HOST-ONLY NETWORK       |
                 |               |                |
                 |  +------------v-------------+  |
                 |  | UBUNTU SERVER VM          |  |
                 |  | The Last Clue CTF Host    |  |
                 |  |                          |  |
                 |  | Apache HTTP — TCP/80     |  |
                 |  | OpenSSH — TCP/22         |  |
                 |  | CTF accounts and files   |  |
                 |  | Challenge evidence       |  |
                 |  +--------------------------+  |
                 +--------------------------------+
```

### Component responsibilities

| Component | Responsibility |
|---|---|
| VirtualBox host | Runs both virtual machines and provides the virtual network |
| Ubuntu Server | Hosts the CTF entry point, SSH access, challenge data, and evidence |
| Kali Linux | Provides the participant's tools and testing workspace |
| Host-only network | Provides isolated communication between the lab VMs and the host |
| Apache TCP/80 | Serves the initial web clue for TLC-01 |
| OpenSSH TCP/22 | Provides intended remote access for the account-based stages |

### Example VM addressing

These addresses are **examples only**. Replace them with the addresses configured in the actual lab.

| Node | Example address |
|---|---|
| Ubuntu CTF server | `192.168.56.10/24` |
| Kali participant VM | `192.168.56.20/24` |
| Example Host-only subnet | `192.168.56.0/24` |

The selected subnet must not conflict with an existing LAN, VPN, or virtual network.

## 5. Network Design

The intended network boundary is a VirtualBox Host-only network. Both VMs attach to the same Host-only network so Kali can access the CTF server without placing the challenge server directly on a public network.

### Intended exposed services

| Service | Port | Purpose |
|---|---:|---|
| Apache HTTP | TCP/80 | Initial web reconnaissance and clue discovery |
| OpenSSH | TCP/22 | Authorized access to CTF user accounts |

The intended exposed services are TCP/22 and TCP/80. Actual listening ports must be checked during implementation; do not assume no other service is running.

### Network security principles

- Keep the demonstration environment isolated.
- Avoid unrestricted bridged networking during the CTF demonstration.
- Use only CTF-specific accounts, credentials, keys, and evidence.
- Restrict firewall rules to the lab network or interface where practical.
- Investigate any unexpected listening service before assessment.
- Use temporary, controlled Internet access only if needed for updates, then disconnect it before isolated testing.

## 6. Challenge Flow

```text
                 +------------------------------+
                 | TLC-01: The Father's         |
                 | First Trace                  |
                 | Apache / robots.txt / clue   |
                 +---------------+--------------+
                                 |
                                 v
                 +------------------------------+
                 | TLC-02: Levin's Photograph   |
                 | Digital clue investigation   |
                 +---------------+--------------+
                                 |
                                 v
                 +------------------------------+
                 | TLC-03: Bella's Scripted Lock|
                 | Standalone Python challenge  |
                 +---------------+--------------+
                                 |
                                 v
                 +------------------------------+
                 | TLC-04: Bella's Ciphered Note|
                 | Cryptographic analysis       |
                 +---------------+--------------+
                                 |
                                 v
                 +------------------------------+
                 | TLC-05: Adam's Deleted        |
                 | Timeline                     |
                 | Digital forensics / PCAP     |
                 +---------------+--------------+
                                 |
                                 v
                 +------------------------------+
                 | TLC-06: The Last Transmission|
                 | Evidence correlation and     |
                 | authorized privilege         |
                 | escalation                   |
                 +---------------+--------------+
                                 |
                                 v
                         +---------------+
                         |  FINAL FLAG   |
                         +---------------+
```

## 7. Challenge Design

| Stage | Name | Primary domain | Intended learning activity |
|---|---|---|---|
| TLC-01 | The Father's First Trace | Web reconnaissance | Inspect the Apache entry point, discover `robots.txt`, and follow the intended clue |
| TLC-02 | Levin's Photograph | Information gathering / metadata | Investigate the provided photograph or image artifact for the next clue |
| TLC-03 | Bella's Scripted Lock | Programming and scripting | Analyze and solve a standalone Python logic/automation challenge |
| TLC-04 | Bella's Ciphered Note | Cryptography | Analyze the implemented cipher and recover the intended information |
| TLC-05 | Adam's Deleted Timeline | Digital forensics and networking | Investigate supplied forensic artifacts and packet-capture evidence |
| TLC-06 | The Last Transmission | Integrated investigation / Linux security | Correlate earlier evidence and complete the deliberately configured final CTF privilege-escalation task |

### Progression

The intended difficulty progression is:

- **Stages 1–2:** Easy
- **Stages 3–4:** Moderate
- **Stage 5:** Moderate–Hard
- **Stage 6:** Hard — capstone

The final challenge should depend on evidence collected earlier. Test every stage to ensure the intended route works and obvious unintended shortcuts do not bypass the challenge.

### Account movement and privilege escalation

The design distinguishes two concepts:

- **Horizontal user transition:** moving from Levin's account to Bella's account at the same general privilege level.
- **Vertical privilege escalation:** using the intentionally configured CTF privilege in the final Adam stage to access a higher privilege level.

The final sudo configuration must be narrow and specific to the challenge. Do not grant broad unrestricted sudo privileges as a shortcut.

## 8. Security Design

| Control | Design intention |
|---|---|
| Virtual network isolation | Keep testing within the authorized lab |
| Limited exposed services | Intend to expose only TCP/22 and TCP/80 on the Ubuntu CTF server |
| CTF-only identities | Avoid real or reused credentials |
| Least privilege | Give each challenge account only the access required for its stage |
| File permissions | Keep restricted flags, private keys, and instructor-only material inaccessible to participants until intended |
| Logging | Retain relevant service and test logs for troubleshooting and demonstration |
| Reset/recovery | Restore a documented initial state between attempts |
| Validation | Verify flags using the implemented platform mechanism or a documented manual process |

These are design requirements, not evidence that each control is already implemented. Record the actual configuration and test results separately.

## 9. Technology Stack

| Technology | Planned purpose |
|---|---|
| Oracle VirtualBox | Virtual machine platform |
| Ubuntu Server | CTF server and evidence host |
| Kali Linux | Participant/testing environment |
| Apache HTTP Server | Stage 1 web entry point |
| OpenSSH | Intended remote access for CTF accounts |
| Python 3 | Standalone programming challenge and optional helper scripts |
| Nmap | Authorized service discovery and verification |
| `curl` / web browser | HTTP inspection |
| ExifTool | Image metadata investigation, if used in TLC-02 |
| Wireshark / `tshark` | PCAP investigation, if used in TLC-05 |
| Shell scripts | Platform setup, verification, or reset automation |

Tools should be listed as implemented only after they have been installed or used in the actual environment.

## 10. Deployment and Validation Boundaries

This README describes architecture and design; it is not proof of a completed deployment. Before assessment, verify and document:

1. Both VMs boot and use the intended Host-only network.
2. The actual IP addresses and interface names.
3. Apache and SSH service status.
4. The actual listening ports and firewall rules.
5. Reachability from Kali to the Ubuntu server.
6. All six challenge paths and their intended solutions.
7. Flag validation behavior for valid and invalid submissions.
8. The reset/recovery procedure.
9. Any deviations from the approved Assignment 01 design and their technical justification.

## 11. Repository Layout

A suggested repository structure is:

```text
The-Last-Clue/
├── README.md
├── docs/
│   ├── architecture.txt
│   ├── network-design.md
│   ├── installation-guide.md
│   ├── reset-recovery.md
│   ├── testing-checklist.md
│   └── screenshots/
├── deployment/
│   ├── ubuntu/
│   │   ├── setup.sh
│   │   ├── configure-firewall.sh
│   │   └── verify-services.sh
│   └── kali/
│       └── participant-setup.md
├── scripts/
├── challenges/
│   ├── TLC-01-fathers-first-trace/
│   ├── TLC-02-levins-photograph/
│   ├── TLC-03-bellas-scripted-lock/
│   ├── TLC-04-bellas-ciphered-note/
│   ├── TLC-05-adams-deleted-timeline/
│   └── TLC-06-last-transmission/
└── evidence/
    └── test-results.md
```

This layout is a recommendation. Keep only files that exist and are appropriate to distribute. Do not commit passwords, private keys, personal data, or instructor-only solutions to a public repository.

## 12. Design Status

Complete this table with verified information before submission.

| Item | Status / record |
|---|---|
| Ubuntu version | `REPLACE_WITH_VERIFIED_VERSION` |
| Kali version | `REPLACE_WITH_VERIFIED_VERSION` |
| VirtualBox version | `REPLACE_WITH_VERIFIED_VERSION` |
| Ubuntu Host-only IP | `REPLACE_WITH_ACTUAL_IP` |
| Kali Host-only IP | `REPLACE_WITH_ACTUAL_IP` |
| Actual listening ports | `REPLACE_WITH_VERIFIED_RESULTS` |
| Flag validation method | `REPLACE_WITH_IMPLEMENTED_METHOD` |
| Reset/recovery method | `REPLACE_WITH_TESTED_METHOD` |
| End-to-end test date | `REPLACE_WITH_DATE` |
| Known limitations | `DOCUMENT_UNRESOLVED_ISSUES` |

---

## Safety Disclaimer

This project is intended for authorized cybersecurity education in a controlled lab. Run scans and tests only against the designated CTF environment. Do not target public, institutional, or third-party systems without explicit authorization.
