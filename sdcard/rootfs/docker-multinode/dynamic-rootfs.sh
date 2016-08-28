# Configures a docker-multinode filesystem
#
# Globals required: 
# ROOT: Path to the docker-multinode filesystem
# PROJROOT: Path to kubernetes-on-arm
rootfs(){

    K8S_DIR=${ROOT}/etc/kubernetes
    SDCARD_METADATA_FILE=${K8S_DIR}/SDCard_metadata.conf

    # Allow root ssh connections when using arch linux
    if [[ ${OSNAME} == "archlinux" && -f ${ROOT}/etc/ssh/sshd_config ]]; then
        echo "PermitRootLogin yes" >> ${ROOT}/etc/ssh/sshd_config
    fi

    # Copy over all addons
    mkdir -p ${ROOT}/etc/kubernetes/addons
    cp ${PROJROOT}/addons/*.yaml ${ROOT}/etc/kubernetes/addons/

    # Inform the newly created SD Cards' scripts about which files to use.
    echo -e "OS=${OSNAME}\nBOARD=${MACHINENAME}" > ${K8S_DIR}/env/env.conf

    # Remember the time we built this SD Card
    echo -e "SDCARD_BUILD_DATE=\"$(date +%d%m%y_%H%M)\"" >> ${SDCARD_METADATA_FILE}

    # Try to fetch latest commit from git
    COMMIT=$(git log --oneline 2>&1 | head -1 | awk '{print $1}')
    if [[ ${COMMIT} != "bash:"* && ${COMMIT} != "fatal:"* ]]; then
        echo "K8S_ON_ARM_COMMIT=${COMMIT}" >> ${SDCARD_METADATA_FILE}
    fi

    # Get version relative to $PROJROOT
    source ${PROJROOT}/version
    echo "K8S_ON_ARM_VERSION=${VERSION}" >> ${SDCARD_METADATA_FILE}

    # Remove the copy of this script
    rm ${ROOT}/dynamic-rootfs.sh
}
