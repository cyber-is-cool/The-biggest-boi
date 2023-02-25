#back up

mkdir /backups

cp /etc/sudoers /backups
cp /etc/passwd /backups
cp -r /var/log /backups
cp /etc/group /backups
cp /etc/shadow /backups
cp /var/spool/mail /backups
u= $( ls /home )
echo $u
for x in $u 
do
echo $x
sudo cp -r /home/$x /backups
done

sleep 2
