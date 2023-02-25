#!/bin/bash
clear
echo update
echo $os
if [[ $os == "Ubuntu" ]]; then	
	apt update >> /log/update
	apt update --fix-missing >> /log/update
	apt list --upgradable >> /log/update
	apt upgrade >> /log/update
elif [[ $os == "Fedora" ]]; then
	dnf check-update
	dnf upgrade

else
	echo "Very bad"
fi

