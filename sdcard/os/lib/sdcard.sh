generaldownload(){

    # Install unzip and 7z if not present
    require unzip unzip
    require 7z p7zip-full

    # We can't write this .img file to /tmp because /tmp has a limit of 462MB
    DLDIR=/var/cache/kubernetes-on-arm
    URL=$1
    ZIPFILE=${DLDIR}/$(basename ${URL})
    IMGNAME=$(echo ${ZIPFILE} | rev | cut -c5- | rev)

    # If the zip filename doesn't end with .img.zip, assume the image name will end with .img
    if [[ $(echo ${IMGNAME} | rev | cut -c-3 | rev) != "img" ]]; then
    	IMGNAME=${IMGNAME}.img
    fi

    # Ensure this page is present
    mkdir -p ${DLDIR}

    # Do not overwrite the .img.zip file if that release already exists
    if [[ ! -f ${ZIPFILE} ]]; then
        curl -sSL ${URL} > ${ZIPFILE}
    fi

    # Do not overwrite the .img file if that release already exists
    if [[ ! -f ${DLDIR}/${IMGNAME} ]]; then

    	# Detect extension and extract
    	case "$(echo ${ZIPFILE} | rev | cut -d. -f1 | rev)") in
			zip)
        		unzip ${ZIPFILE} -d ${DLDIR};;
        	7z)
				7z x -o${DLDIR} ${ZIPFILE};;
		esac
    fi

    dd if=${DLDIR}/${IMGNAME} of=${SDCARD} bs=4M

    sync

    # Clear old mounts, if any
    umount ${PARTITION2} >> ${LOGFILE} 2>&1

    sync

    mount ${PARTITION2} ${ROOT}
}

umount_root(){
    umount ${ROOT}
}
