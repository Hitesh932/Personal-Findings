#!/bin/bash
PGUSER="postgres"
PGPASSWORD="welcome@6655"
DBNAME="smartrecon_db"
BACKUP_DIR="/nclbrdb/mnt/appln/DB_backup"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/${DBNAME}_backup_${DATE}.sql"

export PGPASSWORD=$PGPASSWORD

pg_dump -U $PGUSER -F c -b -v -f $BACKUP_FILE $DBNAME

# Check for errors
if [ $? -eq 0 ]; then
  echo "Backup successful: $BACKUP_FILE"
else
  echo "Backup failed"
fi
unset PGPASSWORD


--------------------------

chmod +x backupscript

----------------------


crontab -e
30 23 * * * /path/to/pg_backup.sh

