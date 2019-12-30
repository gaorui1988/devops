#!/bin/bash


set -xe

#env
JENKINS_BASE=/home/build/jenkins
JOB_DIR=$JENKINS_BASE/jobs
BAK_DIR=$JENKINS_BASE/gaorui_bak
REMOTE_HOST=192.168.12.186
REMOTE_DIR=/var/jenkins_home/

#function
bak_stm(){
for dir in `cat $BAK_DIR/stm_list.txt`
do
  echo -e "\033[32m $dir starting backup \033[0m" 
  cd $JOB_DIR
  tar zcvf $BAK_DIR/stm/$dir.tar.gz --exclude=$dir/workspace --exclude=$dir/builds $dir/*
  FILE="$BAK_DIR/stm/$dir.tar.gz"
  if [ -e $FILE ]
  then
    echo -e "\033[32m ----$dir JenkinsJob back YES---- \033[0m"
  else
    echo -e "\033[31m ----$dir JenkinsJob back NO---- \033[0m"
  fi
done
}

bak_eaas(){
for dir in `cat $BAK_DIR/eaas_list.txt`
do
  echo -e "\033[32m $dir starting backup \033[0m" 
  cd $JOB_DIR
  tar zcvf $BAK_DIR/eaas/$dir.tar.gz --exclude=$dir/workspace --exclude=$dir/builds $dir/*
  FILE="$BAK_DIR/eaas/$dir.tar.gz"
  if [ -e $FILE ]
  then
    echo -e "\033[32m ----$dir JenkinsJob back YES---- \033[0m"
  else
    echo -e "\033[31m ----$dir JenkinsJob back NO---- \033[0m"
  fi
done
}

bak_eaas_upgrade(){
for dir in `cat $BAK_DIR/eaas_upgrade_list.txt`
do
  echo -e "\033[32m $dir starting backup \033[0m" 
  cd $JOB_DIR
  tar zcvf $BAK_DIR/eaas_upgrade/$dir.tar.gz --exclude=$dir/workspace --exclude=$dir/builds $dir/*
  FILE="$BAK_DIR/eaas_upgrade/$dir.tar.gz"
  if [ -e $FILE ]
  then
    echo -e "\033[32m ----$dir JenkinsJob back YES---- \033[0m"
  else
    echo -e "\033[31m ----$dir JenkinsJob back NO---- \033[0m"
  fi
done
}

rsync_job(){

cd $BAK_DIR
tree -L 2

echo  "\n"
read -p "copy JenkinsJobs to $REMOTE_HOST yes/no :" choose
if [ $choose = "yes" ]
then
  #rsync -av stm eaas eaas_upgrade $REMOTE_HOST:/opt/
  rsync -av eaas $REMOTE_HOST:/opt/
fi
if [ $choose = "no" ]
then
  exit
fi
}


[ $# -gt 0 ] && mode="$1"
case $mode in
  stm)
    echo -e "\033[32m stm backup \033[0m"
    bak_stm
    ;;
  eaas)
    echo -e "\033[32m eaas backup \033[0m"
    bak_eaas
    ;;
  eaas-upgrade)
    echo -e "\033[32m eaas-upgrade backup \033[0m"
    bak_eaas_upgrade
    ;;
  all)
    echo -e "\033[32m eaas-upgrade backup \033[0m"
    bak_stm
    bak_eaas
    bak_eaas_upgrade
    ;;
  copy)
    echo -e "\033[32m RSYNC to $REMOTE_HOST \033[0m"
    rsync_job
    ;;
  *)
    echo "USAGE: stm|eaas|eaas-upgrade|all|copy"
  ;;
esac
