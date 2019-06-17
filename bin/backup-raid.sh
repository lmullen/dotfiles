#!/usr/bin/env bash

# Backup RAID array to external 4TB disk
echo "Backing up RAID at /media/data to external hard disk."
echo "NB: This does not include the Postgres database."
BACKUPDIR=/media/backup/DATA
mkdir -p $BACKUPDIR
rsync -avp --progress --stats --delete --exclude=postgresql --exclude=chronam-wget /media/data/* $BACKUPDIR

