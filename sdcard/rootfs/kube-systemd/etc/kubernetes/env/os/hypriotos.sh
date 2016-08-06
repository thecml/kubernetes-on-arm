os_install(){

    # Update the system
    os_upgrade

    # Write the DNS options to the file.
    updateline /etc/dhcp/dhclient.conf "prepend domain-search" "prepend domain-search \"default.svc.${DNS_DOMAIN}\",\"svc.${DNS_DOMAIN}\",\"${DNS_DOMAIN}\";"
    updateline /etc/dhcp/dhclient.conf "prepend domain-name-servers" "prepend domain-name-servers ${DNS_IP};"

    systemctl disable cluster-lab
}


os_upgrade(){
    echo "Upgrading packages..."
    apt-get update -y && apt-get upgrade -y
}

os_post_install(){
    # Reflect the new hostname in /boot/device-init.yaml
    newhostname=$(hostnamectl | grep hostname | awk '{print $3}')
    sed -i "/hostname:/c\hostname: ${newhostname}" /boot/device-init.yaml
}
