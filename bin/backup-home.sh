#!/usr/bin/env bash

# Backup RAID array to external 4TB disk
echo "Backing up home at /home/lmullen to external hard disk"
mkdir -p /media/lmullen/BACKUP-RAID/HOME
rsync -avP --delete /home/lmullen/* /media/lmullen/BACKUP-RAID/HOME/

