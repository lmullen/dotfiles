#!/usr/bin/env bash
set -euo pipefail

NOTES_DIR="$HOME/notes"
BACKUP_DIR="$HOME/backups/notes"
DATE=$(date -u +%Y-%m-%dT%H%M%SZ)
BACKUP_FILE="$BACKUP_DIR/notes-backup-$DATE.zip"

# Verify source directory exists
if [ ! -d "$NOTES_DIR" ]; then
  echo "Error: notes directory does not exist: $NOTES_DIR" >&2
  exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create zip archive using relative paths
(cd "$(dirname "$NOTES_DIR")" && zip -r -q "$BACKUP_FILE" "$(basename "$NOTES_DIR")" -x "*/.git/*")

echo "Backup created: $BACKUP_FILE"
