BASE=("luxas/raspbian" "luxas/alpine" "luxas/archlinux")
DEPS=(
	# ON RASPBIAN
	"luxas/go:luxas/raspbian" 
	

	# ON NODE
	"k8s/web:luxas/nodejs"

	# ON GO
	"luxas/dockviz:luxas/go" 
	"luxas/registry:luxas/go" 
	"k8s/build:luxas/go"

	# ON K8S BUILD
	"k8s/hyperkube:k8s/build"
	"k8s/flannel:k8s/build"
	"k8s/pause:k8s/build"
	"k8s/etcd:k8s/build luxas/alpine"

	# ON ARCH
	"luxas/docker-client:luxas/archlinux"

	# ON ALPINE
	"luxas/nginx:luxas/alpine"
    "luxas/nodejs:luxas/alpine"
)