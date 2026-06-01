#!/bin/bash
# job_efficiency.sh
# Analyse efficiency of recent Slurm jobs for a user.
# Reports CPU and memory waste.
#
# Usage: bash job_efficiency.sh [username] [nb_jobs]
# Example: bash job_efficiency.sh guillaumelumin 20

set -euo pipefail

USERNAME=${1:-$(whoami)}
NB_JOBS=${2:-10}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Efficiency report for: $USERNAME (last $NB_JOBS jobs)"
echo "---"

sacct -u "$USERNAME" \
    -n \
    --jobs=$(sacct -u "$USERNAME" -n --format=JobID | head -"$NB_JOBS" | tr '\n' ',' | sed 's/,$//') \
    --format=JobID,JobName,State,Elapsed,CPUTime,MaxRSS,ReqMem,ExitCode \
    2>/dev/null || log "sacct not available or no jobs found"

echo "---"
log "Tip: compare MaxRSS vs ReqMem to calibrate memory requests"
log "Tip: compare Elapsed*CPUs vs CPUTime to check CPU efficiency"
