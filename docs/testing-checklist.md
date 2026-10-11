# The Last Clue — Testing Checklist

> **Purpose:** Use this checklist to record real test results for Assignment 02. Mark an item as passed only after performing the test on the actual CTF environment.

## 1. Test result legend

Use one status for each test:

- `PASS` — executed and met the expected result.
- `FAIL` — executed but did not meet the expected result.
- `NOT TESTED` — not executed yet.
- `BLOCKED` — cannot be tested until a dependency is fixed.

Do not mark a test as passed based only on a configuration file or a screenshot of a plan.

## 2. Environment and isolation

| ID | Test | Expected result | Status | Evidence / notes |
|---|---|---|---|---|
| ENV-01 | Ubuntu VM boots | Login prompt or desktop is available | NOT TESTED | `ADD_EVIDENCE` |
| ENV-02 | Kali VM boots | Participant environment is available | NOT TESTED | `ADD_EVIDENCE` |
| ENV-03 | Both VMs use intended Host-only network | Adapter and subnet match the documented design | NOT TESTED | `ADD_EVIDENCE` |
| ENV-04 | Network isolation reviewed | No unintended bridged/public path is active for the demo | NOT TESTED | `ADD_EVIDENCE` |
| ENV-05 | IP configuration checked | Actual addresses are recorded and do not conflict | NOT TESTED | `ADD_EVIDENCE` |

Useful commands:

```bash
ip -br address
ip route
```

Run on both VMs.

## 3. Services and ports

| ID | Test | Expected result | Status | Evidence / notes |
|---|---|---|---|---|
| NET-01 | Apache service status | Apache is active if Stage 1 is deployed | NOT TESTED | `ADD_EVIDENCE` |
| NET-02 | SSH service status | OpenSSH is active if SSH stages are deployed | NOT TESTED | `ADD_EVIDENCE` |
| NET-03 | Listening sockets inspected | Actual listening ports are recorded | NOT TESTED | `ADD_EVIDENCE` |
| NET-04 | Kali scans Ubuntu TCP/22 and TCP/80 | Results match the intended design | NOT TESTED | `ADD_EVIDENCE` |
| NET-05 | HTTP request from Kali | The intended Stage 1 page responds | NOT TESTED | `ADD_EVIDENCE` |
| NET-06 | Authorized CTF SSH test | Intended account authentication behaves as designed | NOT TESTED | `ADD_EVIDENCE` |

Commands on Ubuntu:

```bash
sudo systemctl status apache2
sudo systemctl status ssh
sudo ss -tulpn
sudo ufw status verbose
```

Commands on Kali (replace the example IP):

```bash
nmap -sV -p 22,80 192.168.56.10
curl -I http://192.168.56.10/
```

## 4. Challenge functionality

Test each stage through its intended solution path. Add details about the actual challenge files and expected result.

| ID | Stage | Test focus | Status | Evidence / notes |
|---|---|---|---|---|
| TLC-01 | The Father's First Trace | Apache page, `robots.txt`, and intended `secret.txt` clue work | NOT TESTED | `ADD_EVIDENCE` |
| TLC-02 | Levin's Photograph | Image/metadata clue leads to the intended next step | NOT TESTED | `ADD_EVIDENCE` |
| TLC-03 | Bella's Scripted Lock | Standalone Python puzzle is solvable with the intended logic | NOT TESTED | `ADD_EVIDENCE` |
| TLC-04 | Bella's Ciphered Note | Cipher challenge produces the intended result | NOT TESTED | `ADD_EVIDENCE` |
| TLC-05 | Adam's Deleted Timeline | Forensic artifacts and PCAP support the intended investigation | NOT TESTED | `ADD_EVIDENCE` |
| TLC-06 | The Last Transmission | Evidence correlation and intended CTF privilege escalation work | NOT TESTED | `ADD_EVIDENCE` |

For every stage, record:

- Starting condition.
- Tools used and why.
- Commands or code used during the test.
- Expected and actual result.
- Flag validation outcome.
- Any defect found and how it was fixed.

## 5. Flag validation

| ID | Test | Expected result | Status | Evidence / notes |
|---|---|---|---|---|
| FLAG-01 | Valid flag submitted | Accepted by the documented validation method | NOT TESTED | `ADD_EVIDENCE` |
| FLAG-02 | Invalid flag submitted | Rejected or marked incorrect | NOT TESTED | `ADD_EVIDENCE` |
| FLAG-03 | Format checked | Expected flag format is enforced or documented | NOT TESTED | `ADD_EVIDENCE` |
| FLAG-04 | Duplicate submission checked, if relevant | Behavior matches design | NOT TESTED | `ADD_EVIDENCE` |

If validation is manual, document and test the manual process instead of claiming an automated validator exists.

## 6. Security and unintended shortcuts

| ID | Test | Expected result | Status | Evidence / notes |
|---|---|---|---|---|
| SEC-01 | Review public-facing services | No unintended service exposure | NOT TESTED | `ADD_EVIDENCE` |
| SEC-02 | Review file permissions | Participants cannot read files that should remain restricted | NOT TESTED | `ADD_EVIDENCE` |
| SEC-03 | Review CTF account privileges | Each account has only intended permissions | NOT TESTED | `ADD_EVIDENCE` |
| SEC-04 | Review final sudo configuration | Only the intended narrowly scoped CTF privilege is available | NOT TESTED | `ADD_EVIDENCE` |
| SEC-05 | Attempt intended-path bypass checks | No trivial unintended shortcut bypasses the challenge | NOT TESTED | `ADD_EVIDENCE` |
| SEC-06 | Confirm lab isolation | Testing remains within authorized CTF systems | NOT TESTED | `ADD_EVIDENCE` |

## 7. Reset and recovery

| ID | Test | Expected result | Status | Evidence / notes |
|---|---|---|---|---|
| RESET-01 | Run documented reset method | Procedure completes without unrelated changes | NOT TESTED | `ADD_EVIDENCE` |
| RESET-02 | Verify initial clues and files | Expected starting state is restored | NOT TESTED | `ADD_EVIDENCE` |
| RESET-03 | Verify services and networking | Box is reachable as documented | NOT TESTED | `ADD_EVIDENCE` |
| RESET-04 | Repeat the first stage | Stage can be attempted again from a clean state | NOT TESTED | `ADD_EVIDENCE` |

## 8. Platform script test

Every group member must include at least one relevant self-developed script or solver according to the assignment brief. For the platform role, a service/port verification or reset-validation script is a suitable option.

| Field | Record |
|---|---|
| Script path | `REPLACE_WITH_REAL_PATH` |
| Author / contributor | `REPLACE_WITH_MEMBER` |
| Purpose | `DESCRIBE_SCRIPT` |
| Inputs | `RECORD_INPUTS` |
| Expected output | `RECORD_EXPECTED_OUTPUT` |
| Actual output | `RECORD_ACTUAL_OUTPUT` |
| Result | `NOT TESTED` |
| Known limitations | `RECORD_LIMITATIONS` |

## 9. Evidence to capture

Capture genuine screenshots or terminal output from the running environment:

- VirtualBox VM list and network adapter settings.
- Ubuntu and Kali IP configuration.
- Ubuntu service status and listening ports.
- Kali-to-Ubuntu service scan.
- Successful HTTP request.
- Authorized SSH test.
- Actual flag validation tests.
- Reset/recovery test.
- Script source and its real output.

Make terminal text readable. Do not fabricate or edit test output to imply a result that did not occur.

## 10. Summary of actual results

Complete after testing:

- Tests passed: `REPLACE_WITH_COUNT`
- Tests failed: `REPLACE_WITH_COUNT`
- Tests not tested: `REPLACE_WITH_COUNT`
- Critical defects found: `RECORD`
- Defects fixed: `RECORD`
- Remaining limitations: `RECORD`
- Final end-to-end test date: `REPLACE_WITH_DATE`
- Tester(s): `RECORD_NAMES_OR_MEMBER_IDS_AS_APPROPRIATE`

## 11. Submission reminder

Assignment 02 requires a working box, a reset/recovery mechanism, and evidence of testing. This checklist is a record template: the actual outcomes must come from running the tests on your own environment.
