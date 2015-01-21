#!/bin/bash

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
