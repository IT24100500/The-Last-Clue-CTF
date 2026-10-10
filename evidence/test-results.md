# Test Results — The Last Clue

## 1. Document Information

| Field | Details |
|---|---|
| Project | The Last Clue — VM-Based CTF |
| Test environment | Ubuntu CTF server VM + Kali Linux participant VM |
| Network mode | VirtualBox Host-Only Adapter (intended design) |
| Tester(s) | [IT24100500 - Sandeepa H.K.C] |
| Test date | [2026-10-10] |
| Build/version | [Commit hash or version] |

> **Evidence integrity:** Enter `PASS` only after observing the expected result. Use `FAIL` when a test does not meet its expected result, and `NOT TESTED` when it has not yet been performed. Attach genuine screenshots, terminal output, or PCAP/log evidence where appropriate. Do not report planned or example results as completed tests.

## 2. Status Definitions

- **PASS** — The observed result matches the expected result.
- **FAIL** — The observed result does not match the expected result.
- **NOT TESTED** — The test has not been performed.
- **BLOCKED** — The test could not be completed because of a documented dependency or environment issue.

## 3. Environment Verification

| ID | Test | Expected result | Actual result / evidence | Status |
|---|---|---|---|---|
| ENV-01 | Confirm both VMs start successfully | Ubuntu and Kali boot without errors | [Record observation and evidence path] | NOT TESTED |
| ENV-02 | Confirm the Ubuntu VM's assigned IP address | Address matches the configured lab network | [Record actual address; do not use an example as evidence] | NOT TESTED |
| ENV-03 | Confirm the Kali VM's assigned IP address | Address matches the configured lab network | [Record actual address] | NOT TESTED |
| ENV-04 | Confirm both VMs use the intended isolated host-only network | Both VMs can communicate on the lab network without unintended bridged exposure | [Record VirtualBox adapter settings and checks] | NOT TESTED |

## 4. Network and Service Tests

| ID | Test | Expected result | Actual result / evidence | Status |
|---|---|---|---|---|
| NET-01 | Test connectivity from Kali to Ubuntu | Ubuntu is reachable on the configured lab network | [Record command and output] | NOT TESTED |
| NET-02 | Test TCP/22 from Kali | SSH is reachable only as permitted by the lab firewall | [Record command and output] | NOT TESTED |
| NET-03 | Test TCP/80 from Kali | Apache serves the intended CTF web content | [Record HTTP status and evidence] | NOT TESTED |
| NET-04 | Inspect listening TCP ports on Ubuntu | Only intended services are listening on reachable interfaces | [Record command output and investigate unexpected ports] | NOT TESTED |
| NET-05 | Test access from outside the lab network, where a separate test host is available | CTF services are not exposed beyond the intended boundary | [Record test setup and result; do not claim this test if no separate host was used] | NOT TESTED |

## 5. Stage-by-Stage Functional Tests

Use the final implemented challenge design and actual flag values stored securely by the project team. Do **not** put real flag values, passwords, private keys, or other secrets in this public test report.

| ID | Stage | Test objective | Expected result | Actual result / evidence | Status |
|---|---|---|---|---|---|
| STG-01 | TLC-01 — The Father's First Trace | Follow the web clue and discover the intended first-stage path | The intended clue chain works; unrelated shortcuts do not reveal later-stage answers | [Add observed result and evidence path] | NOT TESTED |
| STG-02 | TLC-02 — Levin's Photograph | Analyze the supplied photograph and follow its intended clue | The intended metadata/clue can be recovered using the designed method | [Add observed result and evidence path] | NOT TESTED |
| STG-03 | TLC-03 — Bella's Scripted Lock | Solve the standalone Python logic challenge | Correct input meets the documented success condition; incorrect input is rejected appropriately | [Add observed result and evidence path] | NOT TESTED |
| STG-04 | TLC-04 — Bella's Ciphered Note | Decode the cryptographic clue using the intended method | The intended plaintext or next clue is recovered | [Add observed result and evidence path] | NOT TESTED |
| STG-05 | TLC-05 — Adam's Deleted Timeline | Analyze the supplied forensic/network evidence | The intended timeline or evidence-based clue can be recovered | [Add observed result and evidence path] | NOT TESTED |
| STG-06 | TLC-06 — The Last Transmission | Correlate evidence and perform the intended final privilege-escalation task | The intended, narrowly scoped CTF privilege path works and reveals the final flag only as designed | [Add observed result and evidence path] | NOT TESTED |

## 6. Flag Validation and Anti-Shortcut Tests

| ID | Test | Expected result | Actual result / evidence | Status |
|---|---|---|---|---|
| FLAG-01 | Submit a correct flag to the configured validator | Accepted and credited for the correct stage | [Record validator response] | NOT TESTED |
| FLAG-02 | Submit an incorrect flag | Rejected without being credited | [Record validator response] | NOT TESTED |
| FLAG-03 | Submit a flag with incorrect capitalization or formatting, if flags are case/format-sensitive | Handled according to the documented flag format | [Record validator response] | NOT TESTED |
| FLAG-04 | Attempt to access a later-stage flag directly before solving its prerequisites | Later-stage flag is not trivially exposed through the intended attack surface | [Record exact check performed] | NOT TESTED |
| FLAG-05 | Search web files, source files, history, and unintended locations for accidentally exposed flags | No unintended flag disclosure is found | [Record scope and commands/tools used] | NOT TESTED |

## 7. Security and Privilege Tests

| ID | Test | Expected result | Actual result / evidence | Status |
|---|---|---|---|---|
| SEC-01 | Review accounts and permissions used by the challenge | Accounts and permissions are limited to the documented CTF purpose | [Record reviewed accounts/permissions] | NOT TESTED |
| SEC-02 | Review sudo rules for the final stage | Only the intended, documented CTF privilege path is permitted | [Record relevant rule review; redact sensitive details if needed] | NOT TESTED |
| SEC-03 | Check for unintended services and exposed files | No unintended service or file provides an easy bypass of the designed path | [Record checks and findings] | NOT TESTED |
| SEC-04 | Confirm no real credentials or personal data are embedded in challenge files | Only synthetic CTF data and credentials are used | [Record review result] | NOT TESTED |
| SEC-05 | Confirm logging is available for relevant service and system activity | Relevant events can be inspected during testing | [Record log locations and a verified example] | NOT TESTED |

## 8. Reset and Recovery Tests

| ID | Test | Expected result | Actual result / evidence | Status |
|---|---|---|---|---|
| REC-01 | Follow the documented reset procedure | The environment returns to its documented initial state | [Record steps and result] | NOT TESTED |
| REC-02 | Repeat the first-stage entry after reset | The intended entry point works again | [Record result] | NOT TESTED |
| REC-03 | Check accounts, permissions, services, and challenge files after reset | State matches the documented baseline | [Record comparison and evidence] | NOT TESTED |
| REC-04 | Confirm reset does not leave unintended credentials, processes, or temporary files | No unintended residual state is found within the checks performed | [Record scope and result] | NOT TESTED |

## 9. End-to-End Test

| ID | Test | Expected result | Actual result / evidence | Status |
|---|---|---|---|---|
| E2E-01 | Complete all six stages from the intended starting point | A participant can follow the designed sequence to the final stage | [Record tester, duration, stage outcomes, and evidence paths] | NOT TESTED |
| E2E-02 | Complete the challenge after a clean reset | The full intended path remains reproducible | [Record result] | NOT TESTED |
| E2E-03 | Have another group member or fresh participant follow the hints | The challenge is understandable and solvable without undocumented help | [Record participant feedback and observed blockers] | NOT TESTED |

## 10. Test Summary

Fill in this summary after executing the tests.

| Measure | Count |
|---|---:|
| Total tests listed | 30 |
| PASS | 0 |
| FAIL | 0 |
| NOT TESTED | 30 |
| BLOCKED | 0 |

> Update the counts above to match the final table statuses. The initial counts indicate that testing has not yet been recorded; they are not a claim that the implementation passed or failed.

### Known Issues / Deviations

- [Issue ID, description, impact, owner, and planned fix]
- [If none, write “None observed during the tests performed” only after completing the relevant checks.]

### Design Deviations

Document any differences between the approved architecture and the implemented environment. Explain why each change was made and what testing was performed to verify it.

- [Deviation / reason / impact / verification evidence]

### Evidence Index

Store genuine supporting evidence in this directory or in appropriately named subdirectories.

| Evidence path | What it demonstrates |
|---|---|
| `evidence/screenshots/` | Genuine screenshots of test execution and results |
| `evidence/logs/` | Relevant service, system, or test logs with sensitive information removed |
| `evidence/pcaps/` | PCAP files used as challenge or test evidence, where applicable |
| `evidence/test-results.md` | This test plan and recorded outcomes |

Do not include real passwords, private keys, session tokens, or unredacted personal information in public evidence.
