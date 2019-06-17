#!/usr/bin/env bash

# Backup home directory to external 4TB disk
DATADIR=/home/lmullen
BACKUPDIR=/media/backup/HOME

echo "Backing up home directory at $DATADIR to $BACKUPDIR."
echo "Note that this does not include docker-store and other files."

mkdir -p $BACKUPDIR
rsync -avP --progress --stats --delete --delete-excluded \
  --exclude go --exclude R --exclude snap --exclude Templates --exclude texmf \
  --exclude docker-store \
  $DATADIR/* $BACKUPDIR

