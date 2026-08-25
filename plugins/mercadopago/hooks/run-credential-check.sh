#!/usr/bin/env bash
#
# Wrapper for validate_mp_credentials.py: resolves a real Python interpreter
# via resolve-python.sh before running it, instead of trusting a bare
# `python3` invoked directly from hooks.json (see #64 — that resolves to the
# Microsoft Store execution-alias stub on Windows and leaks handles/commit
# charge in the AppXSvc service on every PreToolUse call).
#
# Fails open (exit 0, same as the previous behavior when the Store stub
# silently did nothing useful) if no real interpreter is found, so this
# change never makes the hook more restrictive than it already was.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PY="$(bash "$SCRIPT_DIR/resolve-python.sh")" || exit 0

exec "$PY" "$SCRIPT_DIR/validate_mp_credentials.py" "$@"
