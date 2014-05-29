#!/bin/bash
LANG=C #needed for perl locale

set -eu

if id -u $ADMIN_USER >/dev/null 2>&1; then
    echo $ADMIN_USER already exists
else
    # Add user and optionally generate a random password.
    #USER_PASSWORD=`openssl rand -base64 32`
    echo User: $ADMIN_USER Password: $USER_PASSWORD
    USER_ENCRYPYTED_PASSWORD=`perl -e 'print crypt("'$USER_PASSWORD'", "aa"),"\n"'`
    useradd -m -d /home/$ADMIN_USER -p $USER_ENCRYPYTED_PASSWORD $ADMIN_USER
    sed -Ei 's/adm:x:4:/$ADMIN_USER:x:4:$ADMIN_USER/' /etc/group
    adduser $ADMIN_USER sudo

    # Set the default shell as bash for user.
    chsh -s /bin/bash $ADMIN_USER
fi

env

# Generate SSH keys
if [ ! -e /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key
fi
if [ ! -e /etc/ssh/ssh_host_dsa_key ]; then
    ssh-keygen -t dsa -N "" -f /etc/ssh/ssh_host_dsa_key
fi

sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Start the ssh service
/usr/sbin/sshd -D
