#!/usr/bin/env bash
#
# Resolves a working Python 3 interpreter, explicitly rejecting the
# Microsoft Store execution-alias stub on Windows.
#
# On Windows, a bare `python3` (and often `python`) resolves to a 0-byte
# binary under `%LOCALAPPDATA%\Microsoft\WindowsApps\` unless a real
# interpreter is installed and ordered earlier on PATH. Invoking that stub
# triggers an AppX deployment-service operation that leaks handles and
# commit charge in the AppXSvc Windows service on every call, with no
# self-cleanup — see #64 for the full investigation.
#
# Usage:
#   PY="$(resolve-python.sh)" || exit 0   # no real interpreter found
#   "$PY" some_script.py
#
# Prints the resolved interpreter's absolute path to stdout and exits 0,
# or exits 1 with no output if no real interpreter is found.

set -uo pipefail

for candidate in python3 python py; do
  resolved="$(command -v "$candidate" 2>/dev/null)" || continue
  [ -n "$resolved" ] || continue
  case "$resolved" in
    *WindowsApps*|*windowsapps*) continue ;;  # Store execution-alias stub
  esac
  [ -s "$resolved" ] || continue  # 0-byte stub, belt-and-suspenders
  printf '%s\n' "$resolved"
  exit 0
done

exit 1
