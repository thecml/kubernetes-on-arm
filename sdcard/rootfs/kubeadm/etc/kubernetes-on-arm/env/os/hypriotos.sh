os_install(){

    # Write the DNS options to the file.
    updateline /etc/dhcp/dhclient.conf "append domain-search" "append domain-search \"default.svc.${DNS_DOMAIN}\",\"svc.${DNS_DOMAIN}\",\"${DNS_DOMAIN}\";"
    updateline /etc/dhcp/dhclient.conf "append domain-name-servers" "append domain-name-servers ${DNS_IP};"

    rm /etc/systemd/system/docker.service.d/overlay.conf
    systemctl daemon-reload
    systemctl restart docker
}

os_post_install(){
    # Reflect the new hostname in /boot/device-init.yaml
    newhostname=$(hostnamectl | grep hostname | awk '{print $3}')
    sed -i "/hostname:/c\hostname: ${newhostname}" /boot/device-init.yaml
}
