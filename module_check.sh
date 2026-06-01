#!/bin/bash
# module_check.sh
# Verify that required modules are available and loadable.
# Useful before submitting a batch job.
#
# Usage: bash module_check.sh module1 module2 ...
# Example: bash module_check.sh Python/3.11 NWChem/7.3.0

set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 module1 module2 ..."
    exit 1
fi

source /etc/profile.d/lmod.sh 2>/dev/null || true

FAILED=0

for mod in "$@"; do
    if module load "$mod" 2>/dev/null; then
        echo "OK:   $mod"
        module unload "$mod" 2>/dev/null || true
    else
        echo "FAIL: $mod — not available"
        FAILED=$((FAILED + 1))
    fi
done

echo "---"
if [[ "$FAILED" -eq 0 ]]; then
    echo "All modules OK"
    exit 0
else
    echo "$FAILED module(s) failed"
    exit 1
fi
