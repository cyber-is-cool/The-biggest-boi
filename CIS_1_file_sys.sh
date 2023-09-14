#! /bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi
#1.1
clear
'''
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


#automounting USB 1.1.9
apt purge autofs
read
clear
# 1.1.10
/bin/bash CIS_1_file_sys_rem.sh usb-storage drivers 
read
clear
'''
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

# 1.3
apt upgrade
# 1.3
apt-cache policy
apt-key list






