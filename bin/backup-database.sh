#!/usr/bin/env bash

set +x

# Backup postgres database to external 4TB disk
echo "Backing up Postgres database to external hard disk"
mkdir -p /media/lmullen/BACKUP-RAID/postgres
pg_dump --format=c --compress=9 -v \
  --file=/media/lmullen/BACKUP-RAID/postgres/researchdb-backup-$(date -Is).dump \
  lmullen


