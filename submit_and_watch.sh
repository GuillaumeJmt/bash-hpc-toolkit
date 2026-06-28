#!/bin/bash
# submit_and_watch.sh
# Submit a Slurm job and monitor it until completion.
#
# Usage: bash submit_and_watch.sh <jobscript>
# Example: bash submit_and_watch.sh gaussian.sh

set -euo pipefail

# --- Configuration ---
POLL_INTERVAL=30
LOGFILE="submit_watch_$(date +%Y%m%d_%H%M%S).log"

# --- Fonctions ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

usage() {
    echo "Usage: $0 <jobscript>"
    exit 1
}

# --- Verification des arguments ---
if [[ $# -ne 1 ]]; then
    usage
fi

JOBSCRIPT="$1"

if [[ ! -f "$JOBSCRIPT" ]]; then
    log "ERROR: jobscript '$JOBSCRIPT' not found"
    exit 1
fi

# --- Nettoyage automatique en cas d'interruption ---
JOB_ID=""
trap 'log "Script interrupted. Job $JOB_ID may still be running."; exit 1' INT TERM

# --- Soumission ---
log "Submitting: $JOBSCRIPT"
SUBMIT_OUTPUT=$(sbatch "$JOBSCRIPT")
JOB_ID=$(echo "$SUBMIT_OUTPUT" | awk '{print $NF}')

if [[ -z "$JOB_ID" ]]; then
    log "ERROR: failed to get job ID from sbatch output"
    exit 1
fi

log "Job submitted: ID=$JOB_ID"

# --- Monitoring ---
while true; do
    STATE=$(squeue -j "$JOB_ID" -h -o "%T" 2>/dev/null || echo "UNKNOWN")

    if [[ -z "$STATE" || "$STATE" == "UNKNOWN" ]]; then
        log "Job $JOB_ID no longer in queue"
        break
    fi

    log "Job $JOB_ID state: $STATE"

    if [[ "$STATE" == "COMPLETED" || "$STATE" == "FAILED" || "$STATE" == "CANCELLED" || "$STATE" == "TIMEOUT" ]]; then
        break
    fi

    sleep "$POLL_INTERVAL"
done

# --- Rapport final ---
log "Final status:"
sacct -j "$JOB_ID" --format=JobID,State,ExitCode,Elapsed,MaxRSS 2>/dev/null || \
    log "sacct not available - check job manually"

log "Log saved to: $LOGFILE"
