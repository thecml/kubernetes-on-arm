os_install(){

    # Write the DNS options to the file.
    updateline /etc/dhcp/dhclient.conf "prepend domain-search" "prepend domain-search \"default.svc.${DNS_DOMAIN}\",\"svc.${DNS_DOMAIN}\",\"${DNS_DOMAIN}\";"
    updateline /etc/dhcp/dhclient.conf "prepend domain-name-servers" "prepend domain-name-servers ${DNS_IP};"

    # Thanks to http://a.frtzlr.com/kubernetes-on-raspberry-pi-3-the-missing-troubleshooting-guide/
    cat >> /etc/sysctl.d/k8s.conf <<-EOF
	net.ipv4.tcp_mtu_probing=1
	vm.swappiness = 10
	EOF
}

os_post_install(){
    # Reflect the new hostname in /boot/device-init.yaml
    newhostname=$(hostnamectl | grep hostname | awk '{print $3}')
    sed -i "/hostname:/c\hostname: ${newhostname}" /boot/device-init.yaml
}
