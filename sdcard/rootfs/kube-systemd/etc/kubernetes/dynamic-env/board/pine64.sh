# This command is run by kube-config when doing "kube-config install"
board_post_install(){
  echo "Setting default storage driver to aufs..."
  sed -e "s@overlay@aufs@" -i $KUBERNETES_CONFIG
}
