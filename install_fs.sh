#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#安装地址勿做修改
install_path=/fs/


# Make sure only root can run our script
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root!" 1>&2
       exit 1
    fi
}


function checkenv(){
		if [[ $OS = "centos" ]]; then
			yum install epel-release -y
			yum -y install libpcap
			yum -y install iptables
			yum install -y java
		else
			apt-get update
			apt-get -y install libpcap-dev
			apt-get -y install iptables
			apt-get install -y default-jre
		fi
}



function checkos(){
    if [ -f /etc/redhat-release ];then
        OS='centos'
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS='debian'
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS='ubuntu'
    else
        echo "Not support OS, Please reinstall OS and retry!"
        exit 1
    fi
}

 
#  Install finalspeed
function install_finalspeed(){
	rootness
	checkos
	checkenv
	mkdir -p $install_path
	echo '' > ${install_path}"server.log"
	printf "You can find all releases at https://github.com/developerdong/finalspeed/releases\n"
	printf "Please input the version you want to install. For example: v1.0.0\n"
	read version
	if ! wget --no-check-certificate https://github.com/developerdong/finalspeed/releases/download/${version}/finalspeed_server.jar -O ${install_path}"fs.jar"; then
	    echo "Failed to download the version, please check it!"
	    exit 1
	fi
    if [ "$OS" == 'centos' ]; then
		if ! wget --no-check-certificate https://raw.githubusercontent.com/developerdong/finalspeed/master/finalspeed-centos -O /etc/init.d/finalspeed; then
			echo "Failed to download finalspeed chkconfig file!"
			exit 1
		fi
		chmod +x /etc/init.d/finalspeed
		chkconfig --add finalspeed
		chkconfig finalspeed on	  
	else
		if ! wget --no-check-certificate https://raw.githubusercontent.com/developerdong/finalspeed/master/finalspeed-debian -O /etc/init.d/finalspeed; then
			echo "Failed to download finalspeed chkconfig file!"
			exit 1
		fi
		chmod +x /etc/init.d/finalspeed
		update-rc.d -f finalspeed defaults
    fi
	/etc/init.d/finalspeed start	
}

# Uninstall finalspeed
function uninstall_finalspeed(){
    printf "Are you sure uninstall finalspeed? (y/n) "
    printf "\n"
    read -p "(Default: n):" answer
    if [ -z $answer ]; then
        answer="n"
    fi
    if [ "$answer" = "y" ]; then
        /etc/init.d/finalspeed stop
        checkos
        if [ "$OS" == 'centos' ]; then
            chkconfig --del finalspeed
        else
            update-rc.d -f finalspeed remove
        fi
        rm -f /etc/init.d/finalspeed
        rm -rf $install_path
        echo "finalspeed uninstall success!"
    else
        echo "uninstall cancelled, Nothing to do"
    fi
}

# Initialization step
action=$1
[ -z $1 ] && action=install
case "$action" in
install)
    install_finalspeed
    ;;
uninstall)
    uninstall_finalspeed
    ;;
*)
    echo "Arguments error! [${action} ]"
    echo "Usage: `basename $0` {install|uninstall}"
    ;;
esac



