# 🕵️ The Last Clue — CTF

> A story-driven, VM-based Capture The Flag project for cybersecurity and penetration-testing education.

## Overview

**The Last Clue** is an educational Capture The Flag (CTF) challenge built around a digital investigation. Participants follow the story of three siblings—**Levin, Bella, and Adam**—as they examine digital evidence and uncover the truth behind their mother's unexplained death.

The project combines narrative-driven investigation with practical cybersecurity tasks, including Linux permissions, user access control, privilege escalation, web-service troubleshooting, protected evidence, and virtual-machine recovery.

## Project goals

- Provide a realistic, story-driven cybersecurity learning experience.
- Teach practical Linux and penetration-testing concepts in a controlled environment.
- Guide participants through a sequence of clues and digital artefacts.
- Demonstrate secure access control and protected evidence handling.
- Validate the challenge through repeatable integration and recovery tests.

## Challenge structure

The challenge is organised into six stages. Each stage introduces new clues or artefacts and progressively expands the investigation.

Participants should:

1. Start from the deployed virtual machine and identify the available evidence.
2. Follow the clue trail through the six stages.
3. Use the supplied accounts, services, and artefacts to progress through the investigation.
4. Analyse access restrictions and protected files.
5. Investigate the web service and resolve the documented HTTP issue where required.
6. Recover the clean challenge state using the provided VirtualBox snapshot evidence.

> The exact challenge answers and final flag are intentionally not included in this README.

## Repository contents

The repository contains the challenge implementation, deployment material, design documentation, stage content, and testing evidence. The integration branch includes the following evidence directory:

### `Member 4 Evidence/`

This directory contains integration-test outputs, screenshots, and re-runnable test scripts:

- `01-end-to-end-tests.png` — End-to-end clue, artefact, key, access-control, and permission checks.
- `02-access-control.png` — Demonstration of denied access and root-only protected files.
- `03-http-defect-and-fix.png` — Web-root permission defect and successful repair.
- `04-reset-before-restore.png` — Controlled snapshot-reset mutation.
- `05-reset-after-restore.png` — Post-restore VM and HTTP-service verification.
- `integration-test-results.txt` — Full integration-test transcript.
- `http-defect-fix-results.txt` — HTTP defect reproduction and recovery transcript.
- `post-restore-verification.txt` — Post-restore service, network, and permission checks.
- `virtualbox-snapshot-tree.txt` — VirtualBox snapshot tree and clean-baseline selection.
- `vm-configuration.txt` — VM resources and restored network/service state.
- `run-member4-tests.sh` — Re-runnable integration-test harness.
- `capture-access-control.sh` — Access-control evidence capture script.
- `capture-http-fix.sh` — HTTP defect/fix evidence capture script.
- `reset-probe.sh` — Controlled hint-file mutation script.
- `verify-reset.sh` — Root-run post-restore verification script.

## Integration and testing

The integration test suite validates:

- Six-stage clue and artefact progression.
- Invalid and valid TLC-03 key behaviour.
- The controlled Bella-to-Adam `sudo` transition.
- Access restrictions for earlier-stage users.
- Root-only answer and final-flag permissions.
- Absence of generated lab credentials from shell history.
- Web-root permission failure and recovery.
- VirtualBox snapshot restoration and post-restore service health.
- Host-only HTTP availability after recovery.

The documented integration run passed the core clue, access-control, privilege-transition, protected-file, HTTP, and recovery checks. See `Member 4 Evidence/README.md` for the detailed test scope, results, and limitations.

## Virtual machine and recovery notes

The challenge is designed to run in a controlled virtual-machine environment. Before making changes during testing or deployment:

1. Confirm the expected VM configuration.
2. Create or select the clean baseline snapshot.
3. Run the challenge or integration tests.
4. Restore the clean snapshot after destructive testing.
5. Verify the host-only network, HTTP service, file permissions, and challenge state.

The integration evidence references these snapshots:

- `Member 4 Evidence - Pre-deployment Recovery Point`
- `Member 4 Evidence - Clean Baseline`

The normal guest account cannot independently inspect some protected post-restore files because those files are root-owned with restrictive permissions. The root-run verification script provides the corresponding privileged check.

## Educational scope and safety

This project is intended for **authorised educational use only**. Run the VM in an isolated lab environment and do not expose challenge services to networks or systems you do not own or have explicit permission to test.

Recommended precautions:

- Use host-only or isolated networking where possible.
- Do not reuse real passwords or credentials.
- Take a clean VM snapshot before testing.
- Restore the baseline snapshot after each challenge session.
- Keep challenge evidence and answer files protected from participants.

## Known limitations

- A standalone flag-submission validator is not currently implemented.
- Git history/contribution evidence is unavailable inside the deployed challenge directory because it is not itself a Git repository.
- The installed stage flow follows the selected `root.txt` and video guide. It may differ from the completed report's Stage 3/4 design; the implementation and tests document the deployed flow.

## Contributors

This project was developed collaboratively as a cybersecurity and penetration-testing education project. Contribution-specific evidence and integration documentation are available in the repository branches and evidence directories.

## License

No license file is currently defined for this repository. Unless a license is added, the repository contents should be treated as all rights reserved and used only with the project owner's permission.
