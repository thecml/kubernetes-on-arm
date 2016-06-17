# This command is run by kube-config when doing "kube-config install"
board_post_install(){
  echo "Board post install ..."
  sed -e "s@overlay@devicemapper@" -i $KUBERNETES_CONFIG
  DOCKER_OPTS_ENV_PARAM="DOCKER_OPTS=\"--storage-opt dm.fs=ext4\""
  echo "Setting Docker daemon environment parameter:${DOCKER_OPTS_ENV_PARAM}"
  echo $DOCKER_OPTS_ENV_PARAM >> $KUBERNETES_CONFIG
}
