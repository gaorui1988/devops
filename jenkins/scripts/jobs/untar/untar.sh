#!/bin/bash

set -xe

#env
JOB_DIR=/var/jenkins_home/jobs
JOB_LIST=/opt/scripts


#function
untar(){
cat $JOB_LIST/job_list.txt | while read name
do
  echo "\n"
  echo -e "\033[32m $name untar to $JOB_DIR  \033[0m"
  cd $JOB_DIR
  tar zxvf $name -C .
done
}

untar
