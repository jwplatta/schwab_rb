#!/usr/bin/env bash
set -euo pipefail

if command -v schwab_rb >/dev/null 2>&1; then
  exec "$(command -v schwab_rb)" "$@"
fi

echo "schwab_rb executable not found in PATH. Install the gem globally on the host machine and ensure the executable is available before using this skill." >&2
exit 1
