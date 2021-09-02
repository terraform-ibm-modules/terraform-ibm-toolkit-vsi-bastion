#!/bin/bash
# disable the auto update
systemctl stop apt-daily.service
systemctl kill --kill-who=all apt-daily.service

# wait until `apt` has been killed and locks released
while ! (systemctl list-units --all apt-daily.service | egrep -q '(dead|failed)')
do
  sleep 1;
done

apt-get update

##
## Enable MFA
##

##### Enable Package Repo #####
yum install epel-release -y

##### Install Google Authenticator #####
yum install google-authenticator qrencode-libs -y

##### Make following changes in  /etc/pam.d/sshd #####
pam_conf1=/etc/pam.d/sshd

##### Update below lines  next to "auth       include      postlogin"#####
### auth    sufficient  pam_listfile.so item=user sense=allow file=/google-auth/authusers ###
### auth required pam_google_authenticator.so nullok  secret=~/.ssh/.google_authenticator  ###

sed -i "/^account    required     pam_sepermit.so/a auth\t\tsufficient\tpam_listfile.so item=user sense=allow file=/google-auth/authusers\nauth\trequired\tpam_google_authenticator.so nullok  secret=~/.ssh/.google_authenticator" $pam_conf1


##### make following changes in /etc/ssh/sshd_config #####
ssh_conf1="/etc/ssh/sshd_config"
###** Uncomment following entry "#ChallengeResponseAuthentication yes" ###

sed -i "/^[#]*ChallengeResponseAuthentication[[:space:]]yes.*/c\ChallengeResponseAuthentication yes" $ssh_conf1


### Comment following entry "ChallengeResponseAuthentication no" ###

sed -i "s/^ChallengeResponseAuthentication[[:space:]]no/#&/" $ssh_conf1

### Change following from "PubkeyAuthentication no" To "PubkeyAuthentication yes" ###

#echo "PubkeyAuthentication yes" >> $ssh_conf1

### Add following entry "AuthenticationMethods keyboard-interactive" ###

#echo "AuthenticationMethods keyboard-interactive" >> $ssh_conf1
echo "AuthenticationMethods publickey" >> $ssh_conf1

echo "Match User demo*" >> $ssh_conf1
echo "    AuthenticationMethods keyboard-interactive" >> $ssh_conf1
echo "    PasswordAuthentication yes" >> $ssh_conf1
echo "Match all" >> $ssh_conf1

### Restart SSH Service ###

systemctl reload sshd

systemctl restart sshd

status=$?
if test $status -eq 0
then
    echo "SSH Daemon  Re-Started successfully"
else
    echo "SSH Daemon Re-Start failed"
fi

#### Status update SSH Service ###

if [ ! -d "/etc/skel/.ssh" ]; then
    mkdir "/etc/skel/.ssh"
    restorecon -Rv "/etc/skel/.ssh/"
    if [ -d "/etc/skel/.ssh" ]; then
       restorecon -Rv "/etc/skel/.ssh/"
    fi
fi

echo 'sh /usr/local/bin/google-auth-check.sh'  >> /etc/skel/.bash_profile


touch /usr/local/bin/google-auth-check.sh

cat <<EOF >>  /usr/local/bin/google-auth-check.sh
#!/bin/bash

if [ ! -f ~/.ssh/.google_authenticator ]; then
    google-authenticator -t -d -r 3 -R 30 -w 10 -f
    mv ~/.google_authenticator ~/.ssh/.google_authenticator
fi
EOF

chmod 755 /usr/local/bin/google-auth-check.sh

###End###

##
## Add motd script
##

cat > /tmp/motd.txt << EOL
#RED='\033[0;31m'
RED='\033[36'
GREEN='\033[0;32m'
ORANGE='\033[0;34m'
PINK='\033[0;35m'
WHITE='\033[0;37m'
RESET='\033[0m'
echo "${PINK}#####${RESET}${RED};5;7mIBM Cloud Financial Services Systems.  Authorized access only!!!${RESET}${PINK}#####${RESET}"
echo "${PINK}#####${RESET}${GREEN}All actions Will be monitored and recorded.${RESET}${PINK}#####${RESET}"
echo "${PINK}#####${RESET}${GREEN}Users are accessing a financial services information system.${RESET}${PINK}#####${RESET}"
echo "${PINK}#####${RESET}${GREEN}Information system usage may be monitored, recorded, and subject to audit.${RESET}${PINK}#####${RESET}"
echo "${PINK}#####${RESET}${GREEN}Unauthorized use of the information system is prohibited and subject to criminal and civil penalties.${RESET}${PINK}#####${RESET}"
echo "${PINK}#####${RESET}${GREEN}Use of the information system indicates consent to monitoring and recording.${RESET}${PINK}#####${RESET}"
EOL

### End ###

##
## Pamscript
##


sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config


#ClientAliveInterval 0

#ClientAliveCountMax 3

sed -i 's/\#ClientAliveInterval 0/ClientAliveInterval 1m/g' /etc/ssh/sshd_config
sed -i 's/\#ClientAliveCountMax 3/ClientAliveCountMax 0/g' /etc/ssh/sshd_config

#System-auth

sed -i '/auth        required                                     pam_env.so/a auth        required      pam_faillock.so preauth silent audit deny=2 unlock_time=100' /etc/pam.d/system-auth

sed -i 's/auth        required      pam_faillock.so preauth silent deny=5 unlock_time=900/ /g' /etc/pam.d/system-auth

sed -i 's/auth        \[default=die\] pam_faillock.so authfail deny=5 unlock_time=900/auth       \[default=die\]  pam_faillock.so  authfail  audit  deny=3  unlock_time=100/g' /etc/pam.d/system-auth


#password-auth


sed -i '/auth        required                                     pam_env.so/a auth        required      pam_faillock.so preauth silent audit deny=2 unlock_time=100' /etc/pam.d/password-auth


sed -i 's/auth        required      pam_faillock.so preauth silent deny=5 unlock_time=900/ /g' /etc/pam.d/password-auth


sed -i 's/auth        \[default=die\] pam_faillock.so authfail deny=5 unlock_time=900/auth       \[default=die\]  pam_faillock.so  authfail  audit  deny=3  unlock_time=100/g' /etc/pam.d/password-auth


systemctl reload sshd

systemctl restart sshd

#Append MOTD

cat /tmp/motd.txt > /etc/profile.d/motd.sh

rm -rf /tmp/motd.txt

