#!/bin/bash
# check_disk.sh
# Check disk usage for a user on HPC storage systems.
# Warns when usage exceeds threshold.
#
# Usage: bash check_disk.sh [username] [threshold_%]
# Example: bash check_disk.sh guillaumelumin 80

set -euo pipefail

# --- Defaults ---
USERNAME=${1:-$(whoami)}
THRESHOLD=${2:-80}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

check_path() {
    local path=$1
    local label=$2

    if [[ ! -d "$path" ]]; then
        log "SKIP: $label ($path) not accessible"
        return
    fi

    local usage
    usage=$(df -h "$path" | awk 'NR==2 {print $5}' | tr -d '%')
    local avail
    avail=$(df -h "$path" | awk 'NR==2 {print $4}')
    local total
    total=$(df -h "$path" | awk 'NR==2 {print $2}')

    if [[ "$usage" -ge "$THRESHOLD" ]]; then
        log "WARNING: $label at ${usage}% (${avail} free of ${total})"
    else
        log "OK: $label at ${usage}% (${avail} free of ${total})"
    fi
}

log "Disk check for user: $USERNAME"
log "Warning threshold: ${THRESHOLD}%"
echo "---"

# Check common HPC paths
check_path "/home/$USERNAME"     "HOME"
check_path "/scratch/$USERNAME"  "SCRATCH"
check_path "/project"            "PROJECT"
check_path "$HOME"               "CURRENT HOME"

echo "---"
log "Done"
