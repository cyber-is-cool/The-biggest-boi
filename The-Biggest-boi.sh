#!/bin/bash

#Check if Root
if [[ $EUID -ne 0 ]]; then
	echo "Run as Root =("
	exit 1
fi
mkdir log
touch /log/update
bash Backup.sh
os="NONE"
if hostnamectl | grep -q 'Ubuntu'; then
	echo ubuntu
	$os="Ubuntu"
fi

if hostnamectl | grep -q 'Fedora'; then
	echo Fedora
	$os="Fedora"
fi


export os="Ubuntu"
bash Update-all.sh
bash Remove-bad.sh

