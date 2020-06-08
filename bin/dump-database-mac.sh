#!/usr/bin/env bash

set +x

# Backup PostgreSQL database
echo "Dumping PostgreSQL database on Schaff"

# Directory is named by date and time
DATE=$(date +%Y-%m-%dT%H-%M-%S)
BASEDIR=/Users/lmullen/backups/postgres/
OUTDIR=$BASEDIR/$DATE
LOGFILE=$BASEDIR/pgdump-schaff-lmullen-$DATE.log

pg_dump --format=d --jobs=4 --compress=5 --verbose --file=$OUTDIR lmullen 2> $LOGFILE

