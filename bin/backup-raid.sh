#!/usr/bin/env bash

# Backup RAID array to external 4TB disk
DATADIR=/data
BACKUPDIR=/media/backup/DATA

echo "Backing up RAID at $DATADIR to $BACKUPDIR."
echo "NB: This does not include the Postgres database which must be backed up separately."

mkdir -p $BACKUPDIR
rsync -avp --progress --stats --delete --exclude=postgresql --exclude=chronam-wget $DATADIR/* $BACKUPDIR 

