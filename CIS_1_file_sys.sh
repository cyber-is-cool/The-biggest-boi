#! /bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi
#1.1
clear

if [ 1 == 2 ]; then

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
'''
clear
#/tmp
cp -v /usr/share/systemd/tmp.mount /etc/systemd/system/
systemctl daemon-reload | systemctl --now enable tmp.mount
echo "tmpfs           /tmp            tmpfs    defaults,rw,nosuid,nodev,noexec,relatime,rw,nosuid,nodev,noexec,relatime  0  0" >> /etc/fstab

#/dev/shm partition
echo "tmpfs           /dev/shm            tmpfs    defaults,noexec,nodev,nosuid  0  0" >> /etc/fstab

####var/tmp partition
#parted /dev/nvme0n1p5
#mount -t ext4 /dev/sda3 /var/tmp
echo "ext4           /var/tmp            ext4   defaults,nosuid,nodev,noexec  0  0" >> /etc/fstab

echo "ext4           /home            ext4   defaults,nodev  0  0" >> /etc/fstab

'''
#automounting USB 1.1.9
apt purge autofs
read
clear
# 1.1.10
/bin/bash CIS_1_file_sys_rem.sh usb-storage drivers 
read
clear

#1.2
apt install aide aide-common -y
clear
rm /etc/systemd/system/aidecheck.service &&
touch /etc/systemd/system/aidecheck.service

echo "[Unit]" >>  /etc/systemd/system/aidecheck.service
echo "Description=Aide Check" >>  /etc/systemd/system/aidecheck.service
echo "" >>  /etc/systemd/system/aidecheck.service
echo "[Service]" >>  /etc/systemd/system/aidecheck.service
echo "Type=simple" >>  /etc/systemd/system/aidecheck.service
echo "ExecStart=/usr/bin/aide.wrapper --config /etc/aide/aide.conf --check" >>  /etc/systemd/system/aidecheck.service
echo "" >>  /etc/systemd/system/aidecheck.service
echo "[Install]" >>  /etc/systemd/system/aidecheck.service
echo "WantedBy=multi-user.target" >>  /etc/systemd/system/aidecheck.service
cat /etc/systemd/system/aidecheck.service

rm /etc/systemd/system/aidecheck.timer &&
touch /etc/systemd/system/aidecheck.timer
echo "[Unit]" >>  /etc/systemd/system/aidecheck.timer
echo "Description=Aide check every day at 5AM" >>  /etc/systemd/system/aidecheck.timer
echo "" >>  /etc/systemd/system/aidecheck.timer
echo "[Timer]" >>  /etc/systemd/system/aidecheck.timer
echo "OnCalendar=*-*-* 05:00:00" >>  /etc/systemd/system/aidecheck.timer
echo "Unit=aidecheck.service" >>  /etc/systemd/system/aidecheck.timer
echo "" >>  /etc/systemd/system/aidecheck.timer
echo "[Install]" >>  /etc/systemd/system/aidecheck.timer
echo "WantedBy=multi-user.target" >>  /etc/systemd/system/aidecheck.timer

chown root:root /etc/systemd/system/aidecheck.*
chmod 0644 /etc/systemd/system/aidecheck.*
systemctl daemon-reload
systemctl enable aidecheck.service
systemctl --now enable aidecheck.timer
read
# 1.3
apt upgrade
# 1.3
read
clear
apt-cache policy
read
clear
apt-key list
read

clear
grep -q "^set superusers" /boot/grub/grub.cfg
if [ $? -eq 0 ]; then
	grep -q "^password" /boot/grub/grub.cfg
	if [ $? -eq 0 ]; then
		echo grub2 username and password is set
	else
		echo ---GRUB2 MISCONFIGURED---
		echo ---PASSWORD-NOT-SET---
		
	fi
else
	grep -q "^password" /boot/grub/grub.cfg
	if [ $? -eq 0 ]; then
		echo ---GRUB2 MISCONFIGURED---
		echo ---PASSWORD-SET-NO-USER-
	fi
fi

grep -q "^set superusers" /boot/grub/grub.cfg
if [ $? -eq 1 ]; then
	grep -q "^password" /boot/grub/grub.cfg
	if [ $? -eq 1 ]; then
	echo grub2 not configured right
fi	
fi

read
clear

grub_test=$(stat -Lc "Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)" /boot/grub/grub.cfg)

if [ "$grub_test" == "Access: (0600/-rw-------) Uid: ( 0/ root) Gid: ( 0/ root)" ] || [ "$grub_test" == "Access: (0400/-r--------) Uid: ( 0/ root) Gid: ( 0/ root)" ]; then
	echo "Grub config file is set correctly"
else
	echo "Grub config file is NOT set correctly"
	chown root:root /boot/grub/grub.cfg
	chmod u-x,go-rwx /boot/grub/grub.cfg
fi

read
clear

root=$(passwd --status root)
if [[ "$root" == *"NP"* ]]; then
	echo No password on root account
	passwd root
else
	echo password on root good
fi


# 1.5

prelink -ua
apt purge prelink
read
clear

touch /etc/sysctl.d/60-kernel_sysctl.conf &&
echo "kernel.randomize_va_space = 2" >> /etc/sysctl.d/60-kernel_sysctl.conf
sysctl -w kernel.randomize_va_space=2
echo "kernel.yama.ptrace_scope = 1" >> /etc/sysctl.d/60-kernel_sysctl.conf
sysctl -w kernel.yama.ptrace_scope=1
echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/60-kernel_sysctl.conf
sysctl -w fs.suid_dumpable=0


service procps force-reload


systemctl stop apport.service
systemctl --now disable apport.service
apt purge apport

read 
clear
cat /etc/systemd/coredump.conf
echo $?
if [ $? -eq 0 ]; then {
	echo "Storage=none" >> /etc/systemd/coredump.conf
	echo "ProcessSizeMax=0" >> /etc/systemd/coredump.conf
	systemctl daemon-reload
}
fi


fi ##

apt install apparmor apparmor-utils
clear
out=$(dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n'apparmor apparmor-utils)
if [[ "$out" == *"not-installed"* ]]; then {
	echo apparmor not installed good
	apt install apparmor apparmor-utils
}
else {
	echo apparmor is good
}
fi

sed -i 's/GRUB_CMDLINE_LINUX=/GRUB_CMDLINE_LINUX="apparmor=1 security=apparmor"/'








