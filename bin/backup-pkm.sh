#!/usr/bin/env bash
# Back up the PKM PostgreSQL database (dotfiles/pkm) to a single compressed
# custom-format dump, then prune old dumps.
#
# Retention: the 30 newest dumps, plus the earliest dump from each of the 12
# most recent months that have one. Everything else is deleted.
#
# pg_dump runs inside the container (so its version always matches the server)
# and writes straight to /backups, which compose bind-mounts from PKM_BACKUP_DIR.
#
# The script talks to the container by name (docker exec pkm-db), not through
# docker compose, so it needs none of the compose variables. This matters under
# launchd, which does not see your shell environment. The one variable it does
# use, PKM_BACKUP_DIR, must match what compose was started with; the plist sets
# it explicitly.
#
# Usage: backup-pkm.sh            dump, then prune
#        backup-pkm.sh --prune-only
set -euo pipefail

CONTAINER="${PKM_CONTAINER:-pkm-db}"
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

# A Docker daemon error here aborts with a nonzero exit under set -e, which
# launchd records in backup-pkm.err. A missing or stopped container is not an
# error; the job simply has nothing to do.
state=$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null || true)
if [ "$state" != "true" ]; then
  log "$CONTAINER container is not running; skipping backup"
  exit 0
fi

STAMP=$(date -u +%Y-%m-%dT%H%M%SZ)
FILE="pkm-$STAMP.dump"
# Inside the container: /backups is the bind mount of BACKUP_DIR.
# Write to a temp name so a failed dump never masquerades as a good one.
docker exec "$CONTAINER" sh -c '
  set -e
  pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc --compress=zstd -f "/backups/'"$FILE"'.tmp"
  mv "/backups/'"$FILE"'.tmp" "/backups/'"$FILE"'"
'
log "wrote $BACKUP_DIR/$FILE ($(du -h "$BACKUP_DIR/$FILE" | cut -f1))"

prune
