#!/bin/bash

#=====================================================================
# Set the following variables as per your requirement
#=====================================================================
# Database host name
MONGO_HOST="192.168.12.166"
# Database port
MONGO_PORT="27017"
# Backup directory
BACKUPS_DIR="/backups/mongo_bak/$MONGO_HOST"
# Database user name
DBUSERNAME="admin"
# Database password
DBPASSWORD=`<.pass.txt`
# Authentication database name
DBAUTHDB="admin"
# Days to keep the backup
DAYSTORETAINBACKUP="15"
#=====================================================================

TIMESTAMP=`date +%F-%H%M`
BACKUP_NAME="db_all_$TIMESTAMP"

echo "Performing backup of all"
echo "--------------------------------------------"
# Create backup directory
if ! mkdir -p $BACKUPS_DIR; then
  echo "Can't create backup directory in $BACKUPS_DIR. Go and fix it!" 1>&2
  exit 1;
fi;

# Create dump  all database
mongodump -h $MONGO_HOST -p $MONGO_PORT --username $DBUSERNAME --password $DBPASSWORD --authenticationDatabase $DBAUTHDB
# Rename dump directory to backup name
mv dump $BACKUP_NAME
# Compress backup
tar -zcvf $BACKUPS_DIR/$BACKUP_NAME.tar.gz $BACKUP_NAME
# Delete uncompressed backup
rm -rf $BACKUP_NAME
# Delete backups older than retention period
find $BACKUPS_DIR -type f -mtime +$DAYSTORETAINBACKUP -exec rm {} +
echo "--------------------------------------------"
echo "Database backup complete!"
