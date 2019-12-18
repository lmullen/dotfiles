#!/usr/bin/env bash

set +x

# Backup PostgreSQL database
echo "Backing up PostgreSQL database"

# Directory is named by date
OUTDIR=/data/backups-db/$(date -Id)
mkdir -p $OUTDIR

# Clean up the directory in case we already tried backing up today
# rm -r $OUTDIR/*

pg_dump --format=d --jobs=6 --compress=5 --verbose --file=$OUTDIR lmullen


