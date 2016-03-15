K8S_PREFIX="kubernetesonarm"

# This list have to be kept in sync with the one in kube-config
IMAGES=(
    "$K8S_PREFIX/etcd"
    "$K8S_PREFIX/flannel"
    "$K8S_PREFIX/hyperkube"
    "$K8S_PREFIX/pause"

    "$K8S_PREFIX/skydns"
    "$K8S_PREFIX/kube2sky"
    "$K8S_PREFIX/exechealthz"

    "$K8S_PREFIX/registry"

    "$K8S_PREFIX/loadbalancer"

    "$K8S_PREFIX/heapster"
    "$K8S_PREFIX/influxdb"
    "$K8S_PREFIX/grafana"
)

KUBE_SCRIPTS_TEMP="/tmp/kubernetes-on-arm-scripts"

parse-path-or-disc(){
    # If the target is a disc, mount it to /tmp
    if [[ $1 == "/dev/"* ]]; then

        DIR=$(mktemp -d $KUBE_SCRIPTS_TEMP.XXXXXX)

        if [[ $(fdisk -l | grep $1 | wc -l) == 1 ]]; then

            # echo "Using partition $1"
            mount $1 $DIR
        else
            # echo "Using partition ${1}1"
            mount ${1}1 $DIR
        fi
        echo $DIR
    else
        echo $1
    fi
}

cleanup-path-or-disc(){

    # If we have mounted a disc to /tmp umount it
    if [[ $1 == "$KUBE_SCRIPTS_TEMP"* ]]; then

        echo "Unmounting the disc"
        umount $1
        rm -r $1
    fi
}