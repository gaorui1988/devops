#!/bin/bash

set -xe

source ./env.conf

#main
StartBak(){
cd $BakDataDescDir
mkdir -p $BakOwner
cd $BakOwner
echo "backup start at $BakDateTime" > $BakLog
echo "----------------------------" >> $BakLog
tar zcvf $BakDataName $BakDataSrcDir
} 


ClearLog(){
find $BakDataDescDir/$BakOwner -type f -name "*.tar.gz" -mtime +$BakDays -exec |rm -rf
}

ScpRemoteHost(){
rsync -av  $BakDataDescDir/$BakOwner/*.tar.gz $BakRemoteHost:$BakRemotePath
}


[ $# -gt 0 ] && mode="$1"
case $mode in
  start_backup)
    echo "---------start backup------------"
    StartBak
    ScpRemoteHost
    ;;
  clear_log)
    echo "---------clear backup logs------------------------"
    ClearLog
    ;;
  *)
    echo "USAGE: start_backup|clear_log"
    ;;
esac


