#! /bin/bash

# Global variables
USERS=$(grep -E "/bin/.*sh" /etc/passwd | grep -v -e root -e `whoami` -e speech-dispatcher | cut -d":" -f1)

DISTRO=$(lsb_release -i | cut -d: -f2 | sed "s/\\t//g")
CODENAME=$(lsb_release -c | cut -d: -f2 | sed "s/\\t//g")
delete_unauthorised_users () {
    # Files necessary: 
    #   * users.txt

    echo -e $USERS | sed "s/ /\\n/g" > accusers.txt
    local INVALID=$(diff -n --suppress-common-lines users.txt accusers.txt | cut -d" " -f5-)

    for user in $INVALID
    do 
        echo "${YELLOW}[!] Removing user: ${user}${RESET}"
        sudo userdel -r $user
    done
    rm accusers.txt
}

delete_unauthorised_sudoers () {
    # Files necessary: 
    #   * sudoers.txt

    local SUDOERS=$(grep "sudo" /etc/group | cut -d":" -f4 | sed "s/,/ /g") 

    echo -e $SUDOERS | sed "s/ /\\n/g" > accsudoers.txt
    local INVALID=$(diff -n --suppress-common-lines sudoers.txt accsudoers.txt | cut -d" " -f5-)
    for sudoer in $INVALID
    do 
        echo "${YELLOW}[!] Removing sudoer: ${sudoer}${RESET}"
        sudo gpasswd -d $sudoer sudo
    done

    rm accsudoers.txt
}

add_new_users () {
    # Files necessary:
    #   NONE

    echo -n "${CLEARSCREEN}"
    echo "${RED}${BOLD}Type 'exit' to stop.${RESET}"
    while read -r -p "Username to create: " && [[ $REPLY != exit ]]; do 
        echo "${GREEN}[+] Added new user and creating new home directory '${REPLY}'${RESET}"
        sudo useradd -m $REPLY
    done
}

sys_accounts() {

l_output=""
l_output2=""
l_valid_shells="^($( awk -F\/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"
a_users=(); a_ulock=() # initialize arrays
while read -r l_user; do # change system accounts that have a valid login shell to nolog shell
echo -e " - System account \"$l_user\" has a valid logon shell, changing shell to \"$(which nologin)\""
usermod -s "$(which nologin)" "$l_user"
done < <(awk -v pat="$l_valid_shells" -F: '($1!~/(root|sync|shutdown|halt|^\+)/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $(NF) ~ pat) { print $1 }' /etc/passwd)
while read -r l_ulock; do # Lock system accounts that aren't locked
echo -e " - System account \"$l_ulock\" is not locked, locking account"
usermod -L "$l_ulock"
done < <(awk -v pat="$l_valid_shells" -F: '($1!~/(root|^\+)/ && $2!~/LK?/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $(NF) ~ pat) {print $1 }' /etc/passwd)

}





sudo apt install -y libpam-cracklib fail2ban
clear
answer=""
read -rp "Delete unauthorised users? (Y|N)" answer
case $answer in 
    y|Y)
        echo "CREATE user.txt file" 
        read -r
            delete_unauthorised_users
            ;;
        n|N)
            ;; # Do nothing
    esac

    echo -n "${CYAN}Delete unauthorised sudoers [${GREEN}y${CYAN}|${RED}N${CYAN}] : ${RESET}"
    read -rp "" answer
    case $answer in 
        y|Y)
            echo
            echo "${YELLOW}You will need to create a file called sudoers.txt with all authorised users.${RESET}"
            echo "${CYAN}Press <enter> after adding ${BOLD}./sudoers.txt${RESET}"
            read -r
            echo "${GREEN}[*] Deleting unauthorised sudoers...${RESET}"
            delete_unauthorised_sudoers
            ;;
        n|N)
            ;;
    esac

    echo -n "${CYAN}Add users [${GREEN}y${CYAN}|${RED}N${CYAN}] : ${RESET}"
    read -rp "" answer
    case $answer in 
        y|Y)
            echo 
            add_new_users 
            ;;
        n|N)
            ;; 
    esac

    ## remove guest
    sudo mkdir -p /etc/lightdm/lightdm.conf.d
    sudo touch /etc/lightdm/lightdm.conf.d/myconfig.conf

    echo "[SeatDefaults]"                   | sudo tee /etc/lightdm/lightdm.conf.d/myconfig.conf > /dev/null
    echo "autologin-user=``"                | sudo tee -a /etc/lightdm/lightdm.conf.d/myconfig.conf > /dev/null
    echo "allow-guest=false"                | sudo tee -a /etc/lightdm/lightdm.conf.d/myconfig.conf > /dev/null
    echo "greeter-hide-users=true"          | sudo tee -a /etc/lightdm/lightdm.conf.d/myconfig.conf > /dev/null
    echo "greeter-show-manual-login=true"   | sudo tee -a /etc/lightdm/lightdm.conf.d/myconfig.conf > /dev/null
    echo "greeter-allow-guest=false"        | sudo tee -a /etc/lightdm/lightdm.conf.d/myconfig.conf > /dev/null
    echo "autologin-guest=false"            | sudo tee -a /etc/lightdm/lightdm.conf.d/myconfig.conf > /dev/null
    echo "AutomaticLoginEnable=false"       | sudo tee -a /etc/lightdm/lightdm.conf.d/myconfig.conf > /dev/null
    echo "xserver-allow-tcp=false"          | sudo tee -a /etc/lightdm/lightdm.conf.d/myconfig.conf > /dev/null
    
    sudo lightdm --test-mode --debug 2> backup/users/lightdm_setup.log
    CONFIGSET=$(grep myconfig.conf backup/users/lightdm_setup.log)  
    if [[ -z CONFIGSET ]] 
    then 
        echo "${RED}LightDM config not set, please check manually.${RESET}"
        read -rp "Press <enter> to continue"
    fi

    sudo service lightdm restart
    # UID 0

    UIDS=$(cut /etc/passwd -d: -f1,3 | grep -v root)
    for i in $UIDS
    do 
        username=$(echo $i | cut -d: -f1)
        user_uid=$(echo $i | cut -d: -f2)
        if [[ $user_uid -eq "0" ]]
        then 
            echo "${RED}${BOLD}Found a root UID user [${username} : uid ${user_uid}] !${RESET}"
            read -rp $'Press <enter> to continue\n'
        fi
    done

    #empty password
    SHADOW=$(sudo cat /etc/shadow)
    for line in $SHADOW
    do 
        password_hash=$(echo $line | cut -d: -f2)
        account=$(echo $line | cut -d: -f1)
        if [[ -z $password_hash  ]];
        then 
            echo "{account}"
            read -rp $'Press <enter> to continue\n'
        fi
    done


    # Order ran 
    # delete_unauthorised_users
    # delete_unauthorised_sudoers
    # add_new_users
    # change_users_passwords
    # users_check_uid_0
    # check_shadow_password
    # disable_guests
    
    

        # Back the file up 
    cp /etc/login.defs backup/pam/login.defs

    # Replace the arguments
    
    sudo sed -ie "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS\\t90/" /etc/login.defs
    sudo sed -ie "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS\\t10/" /etc/login.defs
    sudo sed -ie "s/PASS_WARN_AGE.*/PASS_WARN_AGE\\t7/" /etc/login.defs
    sudo sed -ie "s/FAILLOG_ENAB.*/FAILLOG_ENAB\\tyes/" /etc/login.defs
    sudo sed -ie "s/LOG_UNKFAIL_ENAB.*/LOG_UNKFAIL_ENAB\\tyes/" /etc/login.defs
    sudo sed -ie "s/LOG_OK_LOGINS.*/LOG_OK_LOGINS\\tyes/" /etc/login.defs
    sudo sed -ie "s/SYSLOG_SU_ENAB.*/SYSLOG_SU_ENAB\\tyes/" /etc/login.defs
    sudo sed -ie "s/SYSLOG_SG_ENAB.*/SYSLOG_SG_ENAB\\tyes/" /etc/login.defs
    sudo sed -ie "s/LOGIN_RETRIES.*/LOGIN_RETRIES\\t5/" /etc/login.defs
    sudo sed -ie "s/ENCRYPT_METHOD.*/ENCRYPT_METHOD\\tSHA512/" /etc/login.defs
    sudo sed -ie "s/LOGIN_TIMEOUT.*/LOGIN_TIMEOUT\\t60/" /etc/login.defs
    useradd -D -f 30
    sudo sed -ie "s/# difok.*/difok\\t60/" /etc/security/pwquality.conf
    sudo sed -ie "s/difok.*/difok\\t60/" /etc/security/pwquality.conf
    
    sudo sed -ie "s/# dictcheck.*/dictcheck\\t1/" /etc/security/pwquality.conf
    sudo sed -ie "s/dictcheck.*/dictcheck\\t1/" /etc/security/pwquality.conf    
    
    RANBEFORE=$(grep "pam_tally2.so" /etc/pam.d/common-auth)
    if [[ -z $RANBEFORE ]]
    then 
        echo "auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800 audit even_deny_root silent" | sudo tee -a /etc/pam.d/common-auth > /dev/null
    fi
    
    sudo sed -i 's/nullok//g' /etc/pam.d/common-auth
    
    #secure system accounts
    sys_accounts()
    
    





