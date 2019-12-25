#!/bin/bash

set -xe
source ./env.conf


InstallZabbixAgent(){ 
rm -rf /opt/packages/zabbix-agent-4.2.8-1.el7.x86_64.rpm 
}


UpdateZabbixAgentConf(){
yes |cp  /root/zabbix_agentd.conf  $base_home/zabbix_agentd.conf
sed -i "s/Hostname=ansible/Hostname=$host_name/g" $base_home/zabbix_agentd.conf

rm -rf /root/env.conf
rm -rf /root/deploy.sh
rm -rf /root/zabbix_agentd.conf
rm -rf /root/zabbix-agent-4.2.8-1.el7.x86_64.rpm
}


[ $# -gt 0 ] && mode="$1"
case $mode in
   install_agent)
     echo "############Install Zabbix Agent#####################" 
     InstallZabbixAgent
     echo "############Install Zabbix Agent END#####################"
     ;;
   update_conf)
     echo "############Update Zabbix Agent Conf#####################"
     UpdateZabbixAgentConf
     echo "############Update Zabbix Agent Conf END#####################"
     exit $?
     ;;
   *)
     echo "usage:$0 install_agent|update_conf"
     exit 1
esac
