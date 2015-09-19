#!/bin/bash
mkdir /var/run/sshd
mkdir /root/.vnc
/usr/bin/supervisord -c /supervisord.conf

while [ 1 ]; do
    #/bin/bash
    /bin/sleep 1000
done
