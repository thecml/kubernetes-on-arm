# Configures a kube-systemd filesystem
#
# Globals required: 
# ROOT: Path to this filesystem
# PROJROOT: Path to kubernetes-on-arm
rootfs(){

    # Allow ssh connections by root to this machine
    if [[ -f $ROOT/etc/ssh/sshd_config ]]; then
        sed -i '/PermitRootLogin/d' $ROOT/etc/ssh/sshd_config
        echo "PermitRootLogin yes" >> $ROOT/etc/ssh/sshd_config
    fi

    # Remove the .sh
    mv $ROOT/usr/bin/kube-config{.sh,}

    # Remove the copy of this script
    rm $ROOT/dynamic-rootfs.sh
}
