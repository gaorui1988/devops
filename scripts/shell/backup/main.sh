#!/bin/bash


#env
DATE=`date +%F-%H%M`

#mongo bak all
echo -e  '\n'

fun_mongo_bak(){
echo "start mongo bak all on $DATE" >> /tmp/mongo_bak.log
cd /opt/scripts
sh mongo_bak.sh
echo "successful"  >> /tmp/mongo_bak.log
}


fun_code_bak(){
echo "start code bak all on $DATE" >> /tmp/code_bak.log
cd /opt/scripts
sh code_bak.sh
echo "successful"  >> /tmp/code_bak.log
}

fun_clean_log(){
echo "start clean vmlogs on $DATE" >> /tmp/clean_log.log
cd /opt/scripts
sh clean_log.sh
echo "successful"  >> /tmp/clean_log.log
}



[ $# -gt 0 ] && mode="$1"

case $mode in
mongo_bak)
  fun_mongo_bak
  ;;
code_bak)
  fun_code_bak
  ;;
clean_log)
  fun_clean_log
  ;;
*)
  echo "Usage: {mongo_bak|code_bak|clean_log}"
esac