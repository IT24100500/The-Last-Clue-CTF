# The Last Clue CTF — Stage 4-6

This branch contains the middle section of the story-driven CTF challenge, focusing on the final three investigative stages of the case.

The full narrative follows the mysterious disappearance of clues tied to the deaths and digital evidence surrounding Levin, Bella, and Adam. These stages continue the forensic and privilege-escalation investigation, moving from local system compromise to timeline reconstruction and packet analysis.

## Overview

Stage 4-6 introduces a progression of security concepts and forensic skills:

- Privilege escalation via a sudo rule that allows Bella to execute a Python script as Adam
- Timeline reconstruction from deleted or hidden evidence
- Network forensics and PCAP analysis to recover the final transmission

## Challenge structure

```text
.
├── README.md
├── challenges/
│   ├── TLC-04-bellas-scripted-lock/
│   │   └── note.py
│   ├── TLC-05-adams-deleted-timeline/
│   │   └── media.txt
│   └── TLC-06-last-transmission/
│       └── pcap_analysis.txt
└──
```

## Stage 4 — Bella's Scripted Lock

Location: `challenges/TLC-04-bellas-scripted-lock/note.py`

This challenge demonstrates a classic Linux privilege escalation path:

- User `bella` can run Python as user `adam` through sudo
- The script is designed to be abused by replacing or manipulating the target script at `/tmp/note.py`
- The goal is to understand how an attacker can turn a constrained sudo rule into code execution as another user

The file contains a practical PoC showing how the attacker can:

- validate the environment
- inspect the target user and GID
- create a malicious payload
- execute commands as `adam`
- restore the original script afterward

This challenge emphasizes safe, authorized security testing and demonstrates how sudoers misconfigurations can become full privilege escalation.

## Stage 5 — Adam's Deleted Timeline

Location: `challenges/TLC-05-adams-deleted-timeline/media.txt`

This stage focuses on digital forensics and timeline reconstruction.

The file contains evidence from `/media/log` showing:

- user login activity
- file access events
- network events around 20:14
- deletion of a file named `transmission.txt`
- notes indicating the suspicious time window and the importance of checking network evidence

The challenge highlights how forensic investigators must correlate:

- access logs
- timeline notes
- hidden or deleted files
- network-related indicators

The hidden file `.deleted_transmission.txt` reveals a clue:

- `PCAP-WINDOW=20:14:00-20:15:00`
- `TLC-05`

This points directly to the relevant time range for the next stage's network analysis.

## Stage 6 — Last Transmission

Location: `challenges/TLC-06-last-transmission/pcap_analysis.txt`

This challenge introduces packet capture analysis.

The included content shows how a PCAP is created in Ubuntu using `scapy` and then inspected with `tshark`.

The likely malicious transmission pattern includes:

- `EVENT=HEARTBEAT`
- `EVENT=FINAL_TRANSMISSION;TOKEN=TLC-06`

This stage teaches the importance of monitoring application-layer payloads in network traffic and identifying relevant indicators hidden inside captured packets.

## Notes

This repository is intended for educational and authorized cybersecurity training only.

Use these materials responsibly:

- validate your environment before testing
- follow ethical security practices
- do not deploy challenge artifacts in production or public systems

## Story context

The Last Clue is a narrative-driven cybersecurity challenge where each stage builds on evidence uncovered from the digital footprint of the story's characters. This branch represents the middle section of the investigation, where the case turns from local compromise into deeper forensic analysis and covert network communications.

## Related branches

The repository is organized as a story progression across challenge stages. This branch specifically covers the sequence:

- Stage 4: Bella's Scripted Lock
- Stage 5: Adam's Deleted Timeline
- Stage 6: Last Transmission

## License and usage

This project is intended for learning and CTF-style practice. Do not use these materials to attack systems without explicit authorization.
