#!/bin/sh

alias rm=rm
alias cp=cp
alias mv=mv

#关闭selinux
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#修改yum超时时间
sed -i '/timeout=.*/d' /etc/yum.conf 
echo 'timeout=60' >>/etc/yum.conf

#关闭防火墙
if [ -f /usr/bin/systemctl ];then
    systemctl disable iptables
    systemctl stop iptables
    systemctl disable firewalld
    systemctl stop firewalld
else
    chkconfig --level 345 iptables off
    service iptables stop
fi

#关闭NOZEROCONF
sed -i '/NOZEROCONF.*/d' /etc/sysconfig/network
echo "NOZEROCONF=yes" >> /etc/sysconfig/network

#关闭NM
sed -i 's#.*NM_CONTROLLED=.*#NM_CONTROLLED="no"#g' /etc/sysconfig/network-scripts/ifcfg-*

#删除mcelog
rm -f /etc/cron.hourly/mcelog.cron

#关闭发邮件
if [ -z "$(egrep MAILCHECK /etc/profile)" ];then
    echo 'unset MAILCHECK'>>/etc/profile
fi
sed -i "s/^MAILTO=.*/MAILTO=\"\"/g" /etc/crontab

#关闭远程sudo执行命令需要输入密码和没有终端不让执行命令问题
sed -i 's/Defaults *requiretty/#Defaults requiretty/g' /etc/sudoers
sed -i 's/Defaults *!visiblepw/Defaults   visiblepw/g' /etc/sudoers

yum -y install wget
wget -O /etc/yum.repos.d/CentOS-Base.repo https://raw.githubusercontent.com/yunweibang/yum.repos.d/master/CentOS-Base.repo
if [ $? != 0 ];then
    echo ---------------------------------
    echo "cannot access raw.githubusercontent.com"
    echo ---------------------------------
    exit
fi
wget -O /etc/yum.repos.d/epel.repo https://raw.githubusercontent.com/yunweibang/yum.repos.d/master/epel.repo
wget -O /etc/yum.repos.d/remi.repo https://raw.githubusercontent.com/yunweibang/yum.repos.d/master/remi.repo
wget -O /etc/yum.repos.d/nginx.repo https://raw.githubusercontent.com/yunweibang/yum.repos.d/master/nginx.repo
yum -y update
yum -y install ansible apr apr-devel apr-util autoconf automake bison bzip2 clang curl dos2unix expat-devel \
freerdp freerdp-devel fping flex gcc gcc-c++ g++ git \
java-1.8.0-openjdk java-1.8.0-openjdk-devel java-1.8.0-openjdk-headless java-1.8.0-openjdk-accessibility \
kde-l10n-Chinese libssh2 libssh2-devel libtool* libpcap-dev masscan make \
net-tools nginx ntpdate nmap ntsysv nodejs npm openssl openssl-devel openssl-libs pam-devel perl perl-devel \
subversion subversion-devel sysstat systemd-devel screen tomcat-native traceroute vim zlib-devel


if [ -f /usr/bin/systemctl ];then
    for i in $(systemctl list-unit-files|egrep 'enabled'|awk '{print $1}'|egrep -v '\.target$|@\.');do
        systemctl disable $i
    done
    systemctl enable mysqld.service
    systemctl enable nginx.service
    systemctl enable php-fpm.service
    systemctl enable postfix.service
    systemctl enable bigweb.service
    systemctl enable bigserver.service
    systemctl enable gitlab-runner.service
    systemctl enable gitlab-runsvdir.service
    systemctl enable zabbix-agent.service
    systemctl enable zabbix-server.service
    systemctl enable es.service
    systemctl enable kibana.service
    systemctl enable es-head.service
    systemctl enable cerebro.service

    systemctl enable auditd.service
    systemctl enable crond.service
    systemctl enable rhel-autorelabel.service
    systemctl enable rhel-configure.service
    systemctl enable rhel-loadmodules.service
    systemctl enable rhel-readonly.service
    systemctl enable rsyslog.service
    systemctl enable sshd.service
    systemctl set-default multi-user.target
    echo 'LANG="zh_CN.UTF-8"'>/etc/locale.conf
    wget -O /etc/systemd/system.conf https://raw.githubusercontent.com/yunweibang/bigops-install/master/system.conf
else
    for i in $(ls /etc/rc3.d/S*|cut -c 15-|egrep -v local);do
        chkconfig --level 345 $i off
    done
    chkconfig --level 345 mysqld on
    chkconfig --level 345 nginx on
    chkconfig --level 345 php-fpm on
    chkconfig --level 345 postfix on
    chkconfig --level 345 bigweb on
    chkconfig --level 345 bigserver on
    chkconfig --level 345 gitlab-runner on
    chkconfig --level 345 gitlab-runsvdir on
    chkconfig --level 345 zabbix-agent on
    chkconfig --level 345 zabbix-server on
    chkconfig --level 345 es on
    chkconfig --level 345 kibana on
    chkconfig --level 345 es-head on
    chkconfig --level 345 cerebro on

    chkconfig --level 345 sysstat on
    chkconfig --level 345 network on
    chkconfig --level 345 rsyslog on
    chkconfig --level 345 haldaemon on
    chkconfig --level 345 crond on
    chkconfig --level 345 auditd on
    chkconfig --level 345 messagebus on
    chkconfig --level 345 udev-post on
    chkconfig --level 345 sshd on
    sed -i 's/^id:.*/id:3:initdefault:/g' /etc/inittab

    yum -y groupinstall chinese-support
    echo 'LANG="zh_CN.UTF-8"'>/etc/sysconfig/i18n
    echo 'SUPPORTED="zh_CN.UTF-8:zh_CN.GB18030:zh_CN:zh:en_US.UTF-8:en_US:en"'>>/etc/sysconfig/i18n
    echo 'SYSFONT="lat0-sun16"'>>/etc/sysconfig/i18n
fi

rm -f /etc/security/limits.d/*
wget -O /etc/security/limits.conf https://raw.githubusercontent.com/yunweibang/bigops-install/master/limits.conf
wget -O /etc/security/limits.d/90-nproc.conf https://raw.githubusercontent.com/yunweibang/bigops-install/master/90-nproc.conf

wget -O /etc/sysctl.conf https://raw.githubusercontent.com/yunweibang/bigops-install/master/sysctl.conf

sed -i '/ \/ .* defaults /s/defaults/defaults,noatime,nodiratime,nobarrier/g' /etc/fstab
sed -i 's/tmpfs.*/tmpfs\t\t\t\/dev\/shm\t\ttmpfs\tdefaults,nosuid,noexec,nodev 0 0/g' /etc/fstab

cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

if [ -z "$(grep ntpdate /var/spool/cron/root)" ];then
    echo '* */6 * * * /usr/sbin/ntpdate -u pool.ntp.org && /sbin/hwclock --systohc > /dev/null 2>&1'>>/var/spool/cron/root
fi

wget -O /bin/clean_mail.sh https://raw.githubusercontent.com/yunweibang/bigops-install/master/clean_mail.sh
if [ -f /bin/clean_mail.sh ];then
    if [ -z "$(grep /bin/clean_mail.sh /var/spool/cron/root)" ];then
        echo '* */6 * * * /bin/sh /bin/clean_mail.sh > /dev/null 2>&1'>>/var/spool/cron/root
    fi
fi

for i in $(ls /sys/class/net|egrep -v 'lo|usb') ; do ethtool -K $i tso off; done
for i in $(ls /sys/class/net|egrep -v 'lo|usb') ; do ethtool -K $i gso off; done
for i in $(ls /sys/class/net|egrep -v 'lo|usb') ; do ethtool -K $i gro off; done

wget -O /etc/ansible/ansible.cfg https://raw.githubusercontent.com/yunweibang/bigops-install/master/ansible.cfg

if [ -e /usr/lib/jvm/java ];then
    sed -i '/^export JAVA_HOME=.*/g' /etc/profile
    sed -i '/^export PATH=$JAVA_HOME.*/g' /etc/profile
    sed -i '/^export CLASSPATH=.*/g' /etc/profile
    echo 'export JAVA_HOME=/usr/lib/jvm/java'>>/etc/profile
    echo 'export PATH=$JAVA_HOME/bin:$PATH:/usr/local/sbin:/usr/local/bin'>>/etc/profile
    echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar'>>/etc/profile
fi

sed -ie '/^$/{N;/\n$/D};' /etc/profile
source /etc/profile

if [ -d /usr/local/lib ];then
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig
fi

if [ -d /usr/local/lib ];then
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig
fi

if [ ! -f /usr/bin/systemctl ];then
    yum -y install telnet-server telnet xinetd
    wget -O /etc/xinetd.d/telnet https://raw.githubusercontent.com/yunweibang/bigops-install/master/telnet
    chkconfig telnet on
    chkconfig xinetd on
    service xinetd start
    if [ -f /etc/securetty ];then
        mv /etc/securetty /etc/securetty.bak
    fi
    cd ~
    if [ -z "$(openssl version|egrep 1.0.2s)" ];then
        if [ ! -f openssl-1.0.2s.tar.gz ];then
            wget -c https://www.openssl.org/source/openssl-1.0.2s.tar.gz
        fi
        if [ -d openssl-1.0.2s ];then
            rm -rf openssl-1.0.2s
        fi
        tar zxvf openssl-1.0.2s.tar.gz
        cd openssl-1.0.2s
        ./config --prefix=/usr shared zlib
        make clean && make && make install
        if [ $? != 0 ];then
            echo ---------------------------------
            echo "install openssl, failed"
            echo ---------------------------------
            exit
        fi
        cd ~
        rm -rf openssl-1.0.2s
    fi

    cd ~
    if [ -z "$(strings /usr/sbin/sshd | grep OpenSSH_8.0p1)" ];then
        if [ ! -f openssh-8.0p1.tar.gz ];then
            wget -c https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.0p1.tar.gz
        fi
        if [ -d openssh-8.0p1 ];then
            rm -rf openssh-8.0p1
        fi
        tar zxvf openssh-8.0p1.tar.gz
        cd openssh-8.0p1
        chmod -R 0600 /etc/ssh/
        ./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam --with-zlib --with-md5-passwords --without-openssl-header-check
        make clean && make && make install
        if [ $? != 0 ];then
            echo ---------------------------------
            echo "install openssh, failed"
            echo ---------------------------------
            exit
        fi
        cp -f ssh_config /etc/ssh/ssh_config
        echo 'StrictHostKeyChecking no' >>/etc/ssh/ssh_config
        echo 'UserKnownHostsFile=/dev/null'>>/etc/ssh/ssh_config
        cp -f sshd_config /etc/ssh/sshd_config
        sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
        sed -i 's/^GSSAPIAuthentication/#GSSAPIAuthentication no/g' /etc/ssh/sshd_config
        sed -i 's/^GSSAPICleanupCredentials/#GSSAPICleanupCredentials no/g' /etc/ssh/sshd_config
        if [ ! -z $(/usr/sbin/sshd -t -f /etc/ssh/sshd_config) ];then
            echo ---------------------------------
            echo 'install openssh failed, please run /usr/sbin/sshd -t -f /etc/ssh/sshd_config'
            echo ---------------------------------
            exit
        fi
        cd ~
        rm -rf openssh-8.0p1
    fi
fi

sed -i 's/^[ ]*StrictHostKeyChecking.*/StrictHostKeyChecking no/g' /etc/ssh/ssh_config

export JAVA_HOME=/usr/lib/jvm/java
export PATH=$JAVA_HOME/bin:$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/lib64:/lib64
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

cd ~
if [ ! -f /usr/local/apr/lib/libtcnative-1.a ];then
    if [ ! -f apr-1.6.5.tar.gz ];then
        wget -c http://archive.apache.org/dist/apr/apr-1.6.5.tar.gz
    fi
    if [ -d apr-1.6.5 ];then
        rm -rf apr-1.6.5
    fi
    tar zxvf apr-1.6.5.tar.gz
    cd apr-1.6.5
    ./configure --prefix=/usr/local/apr
    make clean && make && make install
    if [ $? != 0 ];then
        echo ---------------------------------
        echo "install apr, failed"
        echo ---------------------------------
        exit
    fi

    cd ~
    rm -rf apr-1.6.5

    if [ ! -f apr-util-1.6.1.tar.gz ];then
        wget -c http://archive.apache.org/dist/apr/apr-util-1.6.1.tar.gz
    fi
    if [ -d apr-util-1.6.1 ];then
        rm -rf apr-util-1.6.1
    fi
    tar zxvf apr-util-1.6.1.tar.gz
    cd apr-util-1.6.1
    ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
    make clean && make && make install
    if [ $? != 0 ];then
        echo ---------------------------------
        echo "install apr-util, failed"
        echo ---------------------------------
        exit
    fi

    cd ~
    rm -rf apr-util-1.6.1

    if [ ! -f tomcat-native-1.2.23-src.tar.gz ];then
        wget -c http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-connectors/native/1.2.23/source/tomcat-native-1.2.23-src.tar.gz
    fi
    if [ -d tomcat-native-1.2.23-src ];then
        rm -rf tomcat-native-1.2.23-src
    fi
    tar zxvf tomcat-native-1.2.23-src.tar.gz
    cd tomcat-native-1.2.23-src/native/
    ./configure --with-apr=/usr/local/apr --with-java-home=/usr/lib/jvm/java
    make clean && make && make install
    if [ $? != 0 ];then
        echo ---------------------------------
        echo "install tomcat-native, failed"
        echo ---------------------------------
        exit
    fi
fi

medusainst(){
    cd ~
    if [ ! -f libssh2-1.8.2.tar.gz ];then
        wget -c https://github.com/yunweibang/bigops-install/raw/master/soft/libssh2-1.8.2.tar.gz
    fi
    if [ -d libssh2-1.8.2 ];then
        rm -rf libssh2-1.8.2
    fi
    tar zxvf libssh2-1.8.2.tar.gz
    cd libssh2-1.8.2
    ./configure
    make clean && make && make install
    if [ $? != 0 ];then
        echo ---------------------------------
        echo "install libssh2, failed"
        echo ---------------------------------
        exit
    fi
    cp -fs /usr/local/lib/libssh2.* /lib/
    cp -fs /usr/local/lib/libssh2.* /lib64/

    cd ~
    if [ ! -f medusa-2.2.tar.gz ];then
        wget -c https://github.com/yunweibang/bigops-install/raw/master/soft/medusa-2.2.tar.gz
    fi
    if [ -d medusa-2.2 ];then
        rm -rf medusa-2.2
    fi
    tar zxvf medusa-2.2.tar.gz
    cd medusa-2.2
    ./configure --enable-module-ssh=yes
    make clean && make && make install
    if [ $? != 0 ];then
        echo ---------------------------------
        echo "install medusa, failed"
        echo ---------------------------------
        exit
    fi
    if [ -f /usr/local/bin/medusa ];then
        ln -sf /usr/local/bin/medusa /usr/bin/medusa
    fi

}

if [ ! -f /usr/bin/medusa ];then
    medusainst
else
    if [ -z "$(/usr/bin/medusa -d|grep ssh.mod)" ];then
        medusainst
    fi
    if [ -z "$(/usr/bin/medusa -V|grep v2.2)" ];then
        medusainst
    fi
fi

if [ -z "$(/usr/bin/nmap -V|grep 7.80)" ];then
    cd ~
    if [ ! -f nmap-7.80.tgz ];then
        wget -c https://github.com/yunweibang/bigops-install/raw/master/soft/nmap-7.80.tgz
    fi
    if [ -d nmap-7.80 ];then
        rm -rf nmap-7.80
    fi
    tar zxvf nmap-7.80.tgz
    cd nmap-7.80
    ./configure
    make clean && make && make install
    if [ $? != 0 ];then
        echo ---------------------------------
        echo "install nmap, failed"
        echo ---------------------------------
        exit
    fi
    if [ -f /usr/local/bin/nmap ];then
        ln -sf /usr/local/bin/nmap /usr/bin/nmap
    fi
fi

if [ ! -f /usr/bin/jq-linux64 ];then
    wget -O /usr/bin/jq-linux64 https://github.com/yunweibang/bigops-install/raw/master/soft/jq-linux64
    chmod 777 /usr/bin/jq-linux64
fi
if [ -z "$(/usr/bin/jq-linux64 -V|grep ^jq-1.6)" ];then
    wget -O /usr/bin/jq-linux64 https://github.com/yunweibang/bigops-install/raw/master/soft/jq-linux64
    chmod 777 /usr/bin/jq-linux64
fi
ln -sf /usr/bin/jq-linux64 /usr/bin/jq

if [ ! -d /opt/ngxlog/ ];then
    mkdir /opt/ngxlog
fi


if [ -d openssl-1.0.2s ];then
    rm -rf openssl-1.0.2s
fi
if [ -d openssh-8.0p1 ];then
    rm -rf openssh-8.0p1
fi
if [ -d apr-1.6.5 ];then
    rm -rf apr-1.6.5
fi
if [ -d apr-util-1.6.1 ];then
    rm -rf apr-util-1.6.1
fi
if [ -d tomcat-native-1.2.23-src ];then
    rm -rf tomcat-native-1.2.23-src
fi
if [ -d libssh2-1.8.2 ];then
    rm -rf libssh2-1.8.2
fi
if [ -d medusa-2.2 ];then
    rm -rf medusa-2.2
fi
if [ -d nmap-7.80 ];then
    rm -rf nmap-7.80
fi

echo
echo ---------------------------------
echo 'Successful initialization'
echo ---------------------------------
echo
