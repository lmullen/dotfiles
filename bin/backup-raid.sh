#!/usr/bin/env bash

# Backup RAID array to external 4TB disk
echo "Backing up RAID at /media/data to external hard disk"
mkdir -p /media/lmullen/BACKUP-RAID/DATA
# rsync -avP --delete --exclude=postgresql /media/data/* /media/lmullen/BACKUP-RAID/DATA/
rsync -avP --delete /media/data/* /media/lmullen/BACKUP-RAID/DATA/

