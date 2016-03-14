K8S_PREFIX="kubernetesonarm"

IMAGES=($(docker images | grep $K8S_PREFIX | grep latest | awk '{print $1}' | sed ':a;N;s/\n/ /;ta'))
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