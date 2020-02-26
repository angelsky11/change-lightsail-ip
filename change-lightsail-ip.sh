#!/bin/bash

#server酱开关，0为关闭，1为开启
NOTIFICATION=0
#server酱api
SERVERCHAN_KEY='YOUR_SERVERCHAN_KEY'

REGION=$1
#ping检测的次数
PINGTIMES=30

readonly NOTIFICATION
readonly SERVERCHAN_KEY
readonly REGION
readonly PINGTIMES

case $(uname) in
	"Darwin")
		# Mac OS X 操作系统
		CHECK_PING="100.0% packet loss"
		;;
	"Linux")
		# GNU/Linux操作系统
		CHECK_PING="100% packet loss"
		;;
	*)
		echo -e "Unsupport System"
		exit 1	
		;;
esac

echo -e '*****************************************************************'
echo -e '***************************** START *****************************'
echo -e '*****************************************************************'

#定义主进程
function main {

	#获取静态ip列表
	local ipjson=$(aws lightsail --region $REGION get-static-ips)
	
	#获取静态ip数量
	local NUM_IP=$(echo $ipjson | jq -r '.|length')
	
	for (( i = 0 ; i < $NUM_IP ; i++ ))
	do
		echo -e '=========================seq '$i' start========================='
		
		#获取ip各项信息
		local OLD_IP=$(echo $ipjson | jq -r '.[]['$i'].ipAddress')
		local INSTANCE_NAME=$(echo $ipjson | jq -r '.[]['$i'].attachedTo')
		local STATIC_IP_NAME=$(echo $ipjson | jq -r '.[]['$i'].name')
		
		echo -e "1. checking vps "$OLD_IP
		
		ping -c $PINGTIMES $OLD_IP > temp.$OLD_IP.txt 2>&1
		grep "$CHECK_PING" temp.$OLD_IP.txt
		if [ $? != 0 ]
		then
			echo -e "2. this IP is alive, nothing happened"
		else
			echo -e "2. this vps is dead, process start"
			#删除原静态ip
			aws lightsail --region $REGION release-static-ip --static-ip-name $STATIC_IP_NAME
			#新建静态ip
			aws lightsail --region $REGION allocate-static-ip --static-ip-name $STATIC_IP_NAME
			#绑定静态ip
			aws lightsail --region $REGION attach-static-ip --static-ip-name $STATIC_IP_NAME --instance-name $INSTANCE_NAME
			#获取新ip
			local instancejson=$(aws lightsail --region $REGION get-instance --instance-name $INSTANCE_NAME)
			local NEW_IP=$(echo $instancejson | jq -r '.[].publicIpAddress')
			
			#发送通知
			if [ $NOTIFICATION = 1 ]
			then
				text="IP地址已更换"
				desp="您在${REGION}的${INSTANCE_NAME}服务器IP:${OLD_IP}已更换至${NEW_IP}。"		
				notification "${text}" "${desp}"
			fi
		fi
		rm -rf temp.$OLD_IP.txt	
	done
}

#定义函数发送serverChan通知
function notification {
	local json=$(curl -s https://sc.ftqq.com/$SERVERCHAN_KEY.send --data-urlencode "text=$1" --data-urlencode "desp=$2")
	errno=$(echo $json | jq .errno)
	errmsg=$(echo $json | jq .errmsg)
	if [ $errno = 0 ]
	then
		echo -e 'notice send success'
	else
		echo -e 'notice send faild'
		echo -e "the error message is ${errmsg}"	
	fi
}

main $REGION

echo -e '*****************************************************************'
echo -e '****************************** END ******************************'
echo -e '*****************************************************************'

exit 0
