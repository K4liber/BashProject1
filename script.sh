#!/bin/sh
PCIP=$(wget -q -O - checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//');
RAM=$(free -m | awk 'NR==2{print $2}')
PROC=$(grep  'cpu cores' /proc/cpuinfo | awk 'NR==1{print $4}')

option=$1;
arg=$2;
changes=0;
email="";

readData()
{
	ipFromData=`sed -n 2p config.data`
	ramFromData=`sed -n 3p config.data`
	procFromData=`sed -n 4p config.data`
	email=`sed -n 1p config.data`

	if [ "$ipFromData" = "" ]; then
		echo "$PCIP" >> config.data
		changes=1
	elif [ "$ipFromData" != "$PCIP" ]; then
		sed 's/$ipFromData/$PCIP/g' config.data
		changes=1
	fi

	if [ "$ramFromData" = "" ]; then
		echo "$RAM" >> config.data
		changes=1
	elif [ "$ramFromData" != "$RAM" ]; then
		sed 's/$ramFromData/$RAM/g' config.data
		changes=1
	fi

	if [ "$procFromData" = "" ]; then
		echo "$PROC" >> config.data
		changes=1
	elif [ "$procFromData" != "$PROC" ]; then
		sed 's/$procFromData/$PROC/g' config.data
		changes=1
	fi
}

sendMail()
{
	ipFromData=`sed -n 2p config.data`
	ramFromData=`sed -n 3p config.data`
	procFromData=`sed -n 4p config.data`
	touch email
	echo "Twoje IP: $ipFromData" >> email
	echo "RAM: $ramFromData MB" >> email
	echo "Ilosc procesorow: $procFromData" >> email
	mail -s "Informacje" $email < email
	rm email
	echo "Wyslano e-mail";
}

writeStatement()
{
	if [ "$changes" = 1 ]; then
		sendMail;
	elif [ "$changes" = 0 ]; then
		echo "Bez zmian."
	elif [ "$changes" = 2 ]; then
		echo "Skonfigurowano adres email."
	elif [ "$changes" = 3 ]; then
		echo "Skonfiguruj adres email."
	fi
}

main()
{
	if [ ! -e config.data ]; then
		changes=3;
	fi

	if [ -e config.data ]; then
		readData;
	elif [ "$option" = "help" ]; then
		echo 'Aby skonfigurowac adres e-mail: \n-e twojadres@xx.xx
		\nNastepnie uruchom skrypt ponownie.';
		changes=4
	fi

	if [ "$option" = "-e" ]; then
		if [ "$arg" = "" ]; then
			echo 'Podaj adres e-mail jako argument.';
			changes=4
		else 
			touch config.data
			echo "$arg" > config.data;
			changes=2;
		fi
	fi

	writeStatement;
}

main;



