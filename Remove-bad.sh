#!/bin/bash
clear
echo Removing uncool things
echo $os

function pp{
	read -p "remove? y/n" yn
	if [[ $yn == y ]]
		return true
	else
		return false
	fi
}

dphg -l | grep john >> /log/remove
if [[ $? -eq 0 ]]; then
	echo Found John
	r=pp
	if [[ $r == true ]]; then
		apt remove john
	fi
fi
	




