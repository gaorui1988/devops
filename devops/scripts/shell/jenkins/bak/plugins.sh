#!/bin/bash
# Author: Sharad Chhetri
# Description: Update all Jenkins plugin
# Version 1.0


set -xe

#env
_JENKINS_URL=http://192.168.12.186:8080
_JENKINS_USER=admin
_JENKINS_PASSWD=4d153b75c6b9457dbff388eec9e0e317
_PLUGINS_LIST=`cat $PWD/list_plugins.txt`


#main
list_plugins(){
java -jar jenkins-cli.jar -s "$_JENKINS_URL" -auth "$_JENKINS_USER:$_JENKINS_PASSWD" -noKeyAuth list-plugins|awk '{ print $1 }'
}

install_plugins(){

for name in $_PLUGINS_LIST
do

  LIST=`java -jar jenkins-cli.jar -s "$_JENKINS_URL" -auth "$_JENKINS_USER:$_JENKINS_PASSWD" -noKeyAuth list-plugins |awk '{ print $1 }'|grep $name`
  if [ -n "$LIST" ];then
    echo "$name plugin installed"
  else
    echo "$name plugin not install,starting install..."
    java -jar jenkins-cli.jar -s "$_JENKINS_URL" -auth "$_JENKINS_USER:$_JENKINS_PASSWD" -noKeyAuth install-plugin $name
  fi

done
}


[ $# -gt 0 ] && mode="$1"
case $mode in
  list)
    echo "------------list plugins---------------"
    list_plugins
    ;;
  install)
    echo "------------install plugins------------"
    install_plugins
    ;;
  *)
    echo "USAGE: list|install"
  ;;
esac
