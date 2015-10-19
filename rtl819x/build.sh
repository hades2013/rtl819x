#!/bin/bash

CONFIG_FILE=$(pwd)/../bootcode_rtl8196c_98/.config
AUTOCONF_FILE=$(pwd)/../bootcode_rtl8196c_98/boot/include/linux/autoconf2.h
AUTOCONF_LINUX=$(pwd)/linux-2.6.30/include/linux/autoconf.h

CONFIG_MACAUTH=n

#-------------CONFIG_MACAUTH-----------
echo " Please select Compiling Option:"
echo "	[0] not support MAC Auth (default) "
echo "	[1] support MAC Auth"
echo -n "  Input a number:"

read macAuth

echo ""
echo ""

case $macAuth in
	0) CONFIG_MACAUTH="n";;
	1) CONFIG_MACAUTH="y";;
esac

if [ -f ${CONFIG_FILE} ];then 
	echo "Here I set to MAC license = ${CONFIG_MACAUTH} as default, you can change it by command"
	while read line
	do 
	script=`echo $line | awk '{print match($0, /^(CONFIG_MACAUTH=)/)}'`
	if [ $script = 1 ];then	
	#echo "$line"	
	sed -i '/CONFIG_MACAUTH=/d' ${CONFIG_FILE}
	fi
	done < $CONFIG_FILE
	if [ ${CONFIG_MACAUTH} = "y" ];then
	echo "CONFIG_MACAUTH=${CONFIG_MACAUTH}" >> $CONFIG_FILE			
	fi
fi

if [ -f ${AUTOCONF_FILE} ];then 
	#echo "Here I set to MAC license = ${CONFIG_MACAUTH} as default, you can change it by command"
	while read line
	do 
	script=`echo $line | awk '{print match($0, /^.*(CONFIG_MACAUTH)/)}'`	
	if [ $script = 1 ];then	
	#echo "$script"	
	#echo "$line"	
	sed -i '/CONFIG_MACAUTH/d' ${AUTOCONF_FILE}
	#echo ${CONFIG_MACAUTH}
	if [ ${CONFIG_MACAUTH} = "y" ];then
		echo "#define  CONFIG_MACAUTH ${macAuth}" >> $AUTOCONF_FILE		
	else
		echo "#undef  CONFIG_MACAUTH" >> $AUTOCONF_FILE		
	fi
	else
		echo "#undef  CONFIG_MACAUTH" >> $AUTOCONF_FILE
	fi
	done < $AUTOCONF_FILE
fi

if [ -f ${AUTOCONF_LINUX} ];then 
	#echo "Here I set to MAC license = ${CONFIG_MACAUTH} as default, you can change it by command"
	while read line
	do 
	script=`echo $line | awk '{print match($0, /^.*(CONFIG_MACAUTH)/)}'`	
	if [ $script = 1 ];then	
	#echo "$script"	
	#echo "$line"	
	sed -i '/CONFIG_MACAUTH/d' ${AUTOCONF_LINUX}
	#echo ${CONFIG_MACAUTH}
	if [ ${CONFIG_MACAUTH} = "y" ];then
		echo "#define  CONFIG_MACAUTH ${macAuth}" >> $AUTOCONF_LINUX		
	else
		echo "#undef  CONFIG_MACAUTH" >> $AUTOCONF_LINUX		
	fi
	else
		echo "#undef  CONFIG_MACAUTH" >> $AUTOCONF_LINUX
	fi
	done < $AUTOCONF_LINUX
fi

exit 0