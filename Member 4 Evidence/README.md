# Member 4 - Integration, Testing and Documentation Evidence

This folder contains the integration-test outputs and screenshots, access-control
and HTTP defect/fix demonstrations, and the VirtualBox snapshot recovery evidence
for **The Last Clue**.

## Evidence

| File | What it demonstrates |
|---|---|
| `01-end-to-end-tests.png` | Six-stage clue/artefact checks, TLC-03 invalid/valid key behavior, the controlled sudo transition, protected-file permissions, and known limitations. |
| `02-access-control.png` | Denied access for the earlier-stage user and root-only answer/final-flag files. |
| `03-http-defect-and-fix.png` | The web-root permission defect (HTTP 404) and repair (HTTP 200). |
| `04-reset-before-restore.png` | Clean hint hash followed by the controlled reset-probe mutation. |
| `05-reset-after-restore.png` | VM resumed from the clean snapshot; host-only address and active HTTP service. |
| `integration-test-results.txt` | Full integration-test transcript. |
| `http-defect-fix-results.txt` | HTTP defect reproduction and recovery transcript. |
| `post-restore-verification.txt` | Snapshot names, post-restore service/HTTP checks, network settings, and the protected-file verification limitation. |
| `virtualbox-snapshot-tree.txt` | Snapshot tree with the clean baseline selected. |
| `vm-configuration.txt` | VM resources and restored network/service state. |
| `run-member4-tests.sh` | Re-runnable integration test harness. |
| `capture-access-control.sh` | Re-runnable access-control capture. |
| `capture-http-fix.sh` | Re-runnable HTTP defect/fix capture. |
| `reset-probe.sh` | Controlled hint-file mutation used for the recovery test. |
| `verify-reset.sh` | Root-run post-restore check for probe removal, permissions, service health, and TLC-03 key behavior. |

## Test scope and result

The end-to-end run passed the six-stage clue and artefact checks, TLC-03 invalid
and valid key cases, the Bella-to-Adam controlled sudo path, the later-stage
access restrictions, and root-only answer/final-flag permissions. It also checked
that the generated lab credential was absent from shell history. The web defect
was reproduced and fixed by correcting web-root traversal permissions.

The recovery test changed the protected Stage 3 hint, captured the changed state,
and restored `Member 4 Evidence - Clean Baseline`. After restore, the VM's
host-only HTTP service was active and returned HTTP 200. VirtualBox reports NIC 1
as disconnected (`null`, cable off) and NIC 2 as host-only; HTTP remained
reachable on the host-only adapter. The hint is root-owned mode `0600`, so the
normal guest account cannot independently inspect its post-restore contents.
The evidence does not claim that this protected-file content check passed;
`verify-reset.sh` provides the root-run check.

## Limitations and design note

- A standalone flag-submission validator is not implemented.
- Git history/contribution evidence is unavailable because the deployed
  challenge directory is not a Git repository.
- The installed stage flow follows the selected `root.txt` and video guide. It
  differs from the completed report's Stage 3/4 design; the implementation and
  tests document the selected flow rather than claiming those designs match.

## Snapshots

- `Member 4 Evidence - Pre-deployment Recovery Point`
- `Member 4 Evidence - Clean Baseline` (restored and selected after the recovery
  exercise)
