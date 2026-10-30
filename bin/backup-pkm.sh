#!/usr/bin/env bash
# Back up the PKM PostgreSQL database (dotfiles/pkm) to a single compressed
# custom-format dump, then prune old dumps.
#
# Retention: the 30 newest dumps, plus the earliest dump from each of the 12
# most recent months that have one. Everything else is deleted.
#
# pg_dump runs inside the container (so its version always matches the server)
# and writes straight to /backups, which compose bind-mounts from BACKUP_DIR.
#
# Usage: backup-pkm.sh            dump, then prune
#        backup-pkm.sh --prune-only
set -euo pipefail

# Default compose file is ../pkm/compose.yaml relative to this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${PKM_COMPOSE_FILE:-$SCRIPT_DIR/../pkm/compose.yaml}"
# Backup dir: env var, else PKM_BACKUP_DIR from pkm/.env (what compose mounts
# at /backups), else the default. Keeps script and compose in agreement.
ENV_FILE="$(dirname "$COMPOSE_FILE")/.env"
if [ -z "${PKM_BACKUP_DIR:-}" ] && [ -f "$ENV_FILE" ]; then
  PKM_BACKUP_DIR=$(sed -nE 's/^PKM_BACKUP_DIR=["'"'"']?([^"'"'"']*)["'"'"']?$/\1/p' "$ENV_FILE" | tail -n 1)
fi
BACKUP_DIR="${PKM_BACKUP_DIR:-$HOME/backups/pkm}"
KEEP_DAILY="${PKM_KEEP_DAILY:-30}"
KEEP_MONTHLY="${PKM_KEEP_MONTHLY:-12}"

# launchd gives a minimal PATH; Docker Desktop's CLI lives in one of these.
export PATH="$PATH:/usr/local/bin:/opt/homebrew/bin:$HOME/.docker/bin"

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }

prune() {
  local all keep
  # Lexicographic order of pkm-<UTC timestamp>.dump is chronological.
  all=$(find "$BACKUP_DIR" -maxdepth 1 -name 'pkm-*.dump' -type f -exec basename {} \; | sort)
  [ -n "$all" ] || return 0

  keep=$(printf '%s\n' "$all" | tail -n "$KEEP_DAILY")
  # Earliest dump in each of the most recent KEEP_MONTHLY months.
  local months m first
  months=$(printf '%s\n' "$all" | sed -E 's/^pkm-([0-9]{4}-[0-9]{2}).*/\1/' | sort -u | tail -n "$KEEP_MONTHLY")
  for m in $months; do
    first=$(printf '%s\n' "$all" | grep "^pkm-$m" | head -n 1)
    keep=$(printf '%s\n%s\n' "$keep" "$first")
  done
  keep=$(printf '%s\n' "$keep" | sort -u)

  local f
  for f in $(comm -23 <(printf '%s\n' "$all") <(printf '%s\n' "$keep")); do
    log "pruning $f"
    rm -f "$BACKUP_DIR/$f"
  done
}

mkdir -p "$BACKUP_DIR"

if [ "${1:-}" = "--prune-only" ]; then
  prune
  exit 0
fi

compose() { docker compose -f "$COMPOSE_FILE" "$@"; }

# A Docker error here (daemon down, bad compose file) aborts with a nonzero
# exit under set -e, which launchd records in backup-pkm.err. An empty result
# just means the container is stopped, which is not an error.
running=$(compose ps --status running -q db)
if [ -z "$running" ]; then
  log "pkm-db container is not running; skipping backup"
  exit 0
fi

STAMP=$(date -u +%Y-%m-%dT%H%M%SZ)
FILE="pkm-$STAMP.dump"
# Inside the container: /backups is the bind mount of BACKUP_DIR.
# Write to a temp name so a failed dump never masquerades as a good one.
compose exec -T db sh -c '
  set -e
  pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc --compress=zstd -f "/backups/'"$FILE"'.tmp"
  mv "/backups/'"$FILE"'.tmp" "/backups/'"$FILE"'"
'
log "wrote $BACKUP_DIR/$FILE ($(du -h "$BACKUP_DIR/$FILE" | cut -f1))"

prune
