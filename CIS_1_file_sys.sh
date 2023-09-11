#! /bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi
#1.1
clear
"""
/bin/bash CIS_1_file_sys_rem.sh cramfs fs
read
clear
/bin/bash CIS_1_file_sys_rem.sh freevxfs fs 
read
clear
/bin/bash CIS_1_file_sys_rem.sh jffs2 fs
read
clear
/bin/bash CIS_1_file_sys_rem.sh hfs fs
read
clear
/bin/bash CIS_1_file_sys_rem.sh hfsplus fs
read
clear
/bin/bash CIS_1_file_sys_rem.sh squashfs fs 
read
clear
/bin/bash CIS_1_file_sys_rem.sh udf fs 
read
clear
"""
clear
#1.2
if [[ $(findmnt -nk /tmp | grep "1777,strictatime,size=2G,noexec,nodev,nosuid") ]]; then
	echo "/tmp is mounted"
else
	echo "/tmp is not mounted"
	cp -v /usr/share/systemd/tmp.mount /etc/systemd/system
	sed -i "/^Options=mode/s/=.*$/=1777,strictatime,size=2G,noexec,nodev,nosuid/" /etc/systemd/system/tmp.mount
	#systemctl daemon-reload
	#systemctl --now enable tmp.mount
fi

