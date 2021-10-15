#!/bin/bash

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


