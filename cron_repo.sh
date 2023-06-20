echo -e "\n\n Displaying Cron.D file\nTo be only used by packages\nUsed for hiding\n\n" >> ~/report/cron.report
echo "___________________________________________________________________________________" >> ~/report/cron.report
ls /etc/cron.d >> ~/report/cron.report

echo -e "\n\n Displaying Cron.hourly file\n\n" >> ~/report/cron.report
echo "___________________________________________________________________________________" >> ~/report/cron.report
ls /etc/cron.hourly >> ~/report/cron.report

echo -e "\n\n Displaying Cron.daily file\n\n" >> ~/report/cron.report
echo "___________________________________________________________________________________" >> ~/report/cron.report
ls /etc/cron.daily >> ~/report/cron.report

echo -e "\n\n Displaying Cron.weekly file\n\n" >> ~/report/cron.report
echo "___________________________________________________________________________________" >> ~/report/cron.report
ls /etc/cron.weekly >> ~/report/cron.report

echo -e "\n\n Displaying Cron.monthly file\n\n" >> ~/report/cron.report
echo "___________________________________________________________________________________" >> ~/report/cron.report
ls /etc/cron.monthly >> ~/report/cron.report 

echo -e "\n\n Displaying all Cron tab users file\n\n" >> ~/report/cron.report
echo "___________________________________________________________________________________" >> ~/report/cron.report
ls /var/spool/cron/crontabs/ >> ~/report/cron.report 

echo -e "\n\nDisplaying cron users \n\n" >> ~/report/cron.report
echo "___________________________________________________________________________________" >> ~/report/cron.report
ji=$(for user in $(cat /etc/passwd | cut -f1 -d: ); do echo $user; crontab -u $user -l >> ~/report/cron.report; if [ $? -eq 0 ];then echo -e "\n BAD-- " $user "--BAD \n" >> ~/report/cron.report; fi; done)
