# This command is run by kube-config when doing "kube-config install"
board_post_install(){
  echo "Board post install ..."
  export INSTALL_STORAGE_DRIVER=devicemapper
}
