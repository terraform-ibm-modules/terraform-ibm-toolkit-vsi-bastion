#!/bin/bash

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
