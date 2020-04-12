#!/bin/bash

#=====================================================================
# Set the following variables as per your requirement
#=====================================================================
# host name
BAK_HOST="10.232.2.50"
# Backup directory
BACKUPS_DIR="/backups/code_bak/$BAK_HOST"
# Bakcup tmp
BAK_TMP="/opt/bak_tmp"
# Days to keep the backup
DAYSTORETAINBACKUP="3"
#=====================================================================

TIMESTAMP=`date +%F-%H%M`
BACKUP_NAME="code_all_$TIMESTAMP"

echo "Performing backup of all"
echo "--------------------------------------------"
# Create backup directory
if ! mkdir -p $BACKUPS_DIR; then
  echo "Can't create backup directory in $BACKUPS_DIR. Go and fix it!" 1>&2
  exit 1;
fi
# Create backup directory tmp
if ! mkdir -p $BAK_TMP; then
  echo "Can't create backup directory in $BAK_TMP Go and fix it!" 1>&2
  exit 1;
fi


# Create dump  all code
rsync  -av /xt /XT /data /etc/nginx /etc/httpd /etc/samba /opt/stm --exclude=/stm/eaasRpmRepo/stm_rpm --exclude=/opt/stm/images --exclude=/opt/stm/packages --exclude=/data/uzer-logs $BAK_TMP/

# Compress backup
tar -zcvf $BACKUPS_DIR/$BACKUP_NAME.tar.gz $BAK_TMP
# Delete uncompressed backup
rm -rf $BAK_TMP
# Delete backups older than retention period
find $BACKUPS_DIR -type f -mtime +$DAYSTORETAINBACKUP -exec rm {} +
echo "--------------------------------------------"
echo "Code backup complete!"