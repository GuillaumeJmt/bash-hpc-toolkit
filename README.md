# Bash HPC Toolkit

Production-grade bash scripts for HPC support engineers.
All scripts follow defensive bash practices (set -euo pipefail, trap, logging).

## Scripts

| Script | Description |
|--------|-------------|
| submit_and_watch.sh | Submit a Slurm job and monitor until completion |
| check_disk.sh | Check disk usage with configurable warning threshold |
| module_check.sh | Verify required modules are available before job submission |
| job_efficiency.sh | Analyse CPU and memory efficiency of recent jobs |
| hpc_health_check.sh | Quick cluster health check for support engineers |

## Usage

    bash submit_and_watch.sh myjob.sh
    bash check_disk.sh guillaumelumin 80
    bash module_check.sh Python/3.11 NWChem/7.3.0
    bash job_efficiency.sh guillaumelumin 20
    bash hpc_health_check.sh

## Design principles

- set -euo pipefail on every script
- Timestamped logging to file and stdout
- trap for cleanup on interruption
- Meaningful exit codes
- Defensive argument checking
- No silent failures
