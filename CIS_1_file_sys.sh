#! /bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi
#1.1
clear

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

df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null | xargs -I '{}' chmod a+t '{}'
#automounting USB 1.1.9
apt purge autofs
# 1.1.10
/bin/bash CIS_1_file_sys_rem.sh usb-storage drivers 
