#!/bin/bash
findActiveInterface()
{
	intfr=
	for i in $( ip a list | grep BROADCAST | awk '{print $2}' | grep -o 'wlan[0-9]*');
	do
		if iwctl station $i show | grep disconnected > /dev/null;then
			continue
		else
			intfr=$i
		fi
	done
	if [ -z $intfr ];then
		intfr=wlan0
	fi
	printf $intfr
}

interface=$(findActiveInterface)

connect(){
	notify-send "Opening Connection Instance"
	iwctl station $interface scan
	echo Scanning for WiFi Networks.....
	sleep 1
	st bash -c "\
	clear;\
	sleep 1;\
	read -t 60;\
	"&
	sleep 1
	max=0
	for i in $(ls /dev/pts)
	do
	  test $i -gt $max 2> /dev/null
	  if [ $? -le 1 ]
	  then
	    max=$i
	  fi
	done
	iwctl station $interface get-networks > /dev/pts/$max;
	echo "Enter WiFi Name to connect to" > /dev/pts/$max
	ssid=$(</dev/pts/$max)

	if iwctl station $interface show | grep disconnected;then
		iwctl station $interface disconnect
	fi

	if [ ! $(iwctl station $interface connect $ssid) ];then
		notify-send "Connected to WiFi network" "$ssid"
	else
		notify-send "Coundn't connect to WiFi Network" "$ssid"
	fi
}
sendNotification(){
	if ! ip a | grep $interface | grep inet;then
		notify-send "Disconnected"
		connect
	elif ip a | grep $interface | grep DOWN; then
		notify-send "No interface"
	elif ip a | grep $interface | grep UP; then
		notify-send " WiFi Connected" "$(iwctl station $interface show | grep Connected\ network | awk '{print $3}')"
	fi
}
case $BUTTON in
	1) sendNotification;;
	3) connect;;
esac