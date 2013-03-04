#!/bin/bash

# a backup script to backup root to an rsync share on the ReadyNAS

# get the password
source /Users/lmullen/.passwords/macbook-backup.pswd

# tell rsync where to get list of excluded files
EXCLUDE="$HOME/.macbook-backup-excludes.txt"

# backup:
# -a = archive
# -r = recursive (not strictly necessary, since -a includes this)
# -v = verbose
# -x = don't cross device boundaries, i.e., ignore mounted volumes
# -z = enable compression
# --delete = remove files that no longer exist in source
# --delete-excluded = deletes files that are part of the excluded list
# --exclude-from = list of files to exclude
# --chmod=a+rwx,g+rwx,o-wx = set readable permissions for destination

rsync -arvxz --delete --delete-excluded --exclude-from=$EXCLUDE --chmod=a+rwx,g+rwx,o-wx / rsync://backup@ReadyNAS.local:/mac-backup/
