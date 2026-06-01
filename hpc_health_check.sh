#!/bin/bash
# hpc_health_check.sh
# Quick health check of a Slurm cluster.
# For HPC support engineers - run before/after maintenance.
#
# Usage: bash hpc_health_check.sh

set -euo pipefail

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

section() {
    echo ""
    echo "=== $* ==="
}

log "HPC Health Check - $(hostname) - $(date)"

section "Slurm daemons"
systemctl is-active slurmctld 2>/dev/null && echo "slurmctld: OK" || echo "slurmctld: DOWN"
systemctl is-active slurmd    2>/dev/null && echo "slurmd:    OK" || echo "slurmd:    DOWN"

section "Node states"
sinfo -N -o "%N %T %C" 2>/dev/null || echo "sinfo not available"

section "Jobs in queue"
squeue -o "%i %u %j %T %M %l" 2>/dev/null || echo "squeue not available"

section "Disk usage"
df -h /home    2>/dev/null || echo "/home not mounted"
df -h /scratch 2>/dev/null || echo "/scratch not mounted"

section "Memory"
free -h 2>/dev/null || vm_stat 2>/dev/null | head -5

section "Load average"
uptime

log "Health check complete"
