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

# Collect the N most recent allocation IDs (-X = allocations only, no
# .batch/.extern steps). `|| true` keeps the script alive under set -e/pipefail
# when off-cluster or when sacct is absent.
JOB_IDS=$(sacct -u "$USERNAME" -X -n --format=JobIDRaw 2>/dev/null \
    | awk 'NF {print $1}' \
    | head -n "$NB_JOBS" \
    | paste -sd, - || true)

if [[ -z "$JOB_IDS" ]]; then
    log "No recent jobs found for $USERNAME (or sacct unavailable)"
    exit 0
fi

sacct -X -j "$JOB_IDS" \
    --format=JobIDRaw,JobName,State,Elapsed,CPUTime,MaxRSS,ReqMem,ExitCode \
    2>/dev/null || log "sacct query failed"

echo "---"
log "Tip: compare MaxRSS vs ReqMem to calibrate memory requests"
log "Tip: compare Elapsed*NCPUS vs CPUTime to check CPU efficiency"
# end of file
