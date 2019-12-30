#!/bin/bash

set -xe

#env
PREFIX_URL=ssh://admin@192.168.11.41:29418
PROJECTS_LIST=/home/git/gaorui


#function
repo_generated(){

while read -r name
do

  echo "\n"
  echo -e "\033[32m project:$name repository Being generated  \033[0m"
  echo "#$name \n $PREFIX_URL/$name \n" >> $PROJECTS_LIST/new/project_repo_list.txt

done < $PROJECTS_LIST/ls-projects_list.txt


}


repo_generated
