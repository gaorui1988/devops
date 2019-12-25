#!/bin/bash
#------------------------------------------#
# FileName:             ssh_auto.sh
# Revision:             1.1.0
# Date:                 2017-07-14 04:50:33
# Author:               gaorui
# Email:                2295463072@qq.com
# Description:          This script can achieve ssh password-free login, 
#                       and can be deployed in batches, configuration


set -xe

#set env
PKGS=`cat ./rpms_list`


#Install rpms
install_rpm(){
if [ `rpm -qa | grep $PKGS |wc -l` -ne 0 ];
then
        echo -e '\n'
        echo -e "\033[34m yes,installed_list: \n$PKGS  \033[0m"
else
        echo -e '\n'
        echo -e "\033[34m Install rpms  \033[0m"
        rpm -ivh ./rpms/*
fi
}

#Create ssh-keygen
#[ ! -f /root/.ssh/id_rsa.pub ] && ssh-keygen -t rsa -p '' &>/dev/null  # 密钥对不存在则创建密钥

create_key(){
if [ -f ~/.ssh/id_rsa ];
then
        echo "id_rsa 文件已存在，将不再重新创建"
else
        echo "id_rsa 文件已不存在，将创建"
        ssh-keygen -f ~/.ssh/id_rsa -t rsa -N '' #这里创建的是免密码登录的密钥，即 空字符串密钥
fi
}

#Batch copy ~/.ssh/id_rsa.pub
ssh_copy(){

cat ./host_ip.txt | while read ip user pwd; do

  sshpass -p $pwd ssh-copy-id -f $ip 2>/dev/null
  echo "===== Copy id_rsa.pub of $ip ====="
  scp /root/.ssh/id_rsa.pub $ip:/$user/.ssh/id_rsa.pub

done
}

ssh_date(){
echo -e '\n\n'
echo -e "\033[34m Verification  \033[0m"

for h in `cat ./host_ip.txt |cut -d " " -f1`

do
       echo -e '\n'
       echo -e "\033[32m $h times  \033[0m"
       ssh $h date
done
}



install_rpm
create_key
ssh_copy
ssh_date

