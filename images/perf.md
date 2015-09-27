# Images performance

## 0.4.0

- luxas/raspbian: 237 s
- luxas/alpine: 38 s

- luxas/go: 1210 s
- luxas/nodejs: 16 s
- luxas/registry: 350 s


- k8s/build: 2208 s
- k8s/hyperkube: 227 s
- k8s/etcd: 13 s
- k8s/flannel: 126 s
- k8s/pause: 1 s
- k8s/web: ?

To get k8s up and running from scratch: 4060 s, 1h 7m 40s

## 0.4.1
 - luxas/raspbian: 224 s
 - luxas/alpine: 39 s
 - luxas/archlinux: 318 s

 - luxas/go: 960 s
 - luxas/nodejs: 10 s
 - luxas/nginx: 12 s
 - luxas/registry: 220 s

 - k8s/build: 699 s
 - k8s/etcd: 17 s
 - k8s/hyperkube: 142 s
 - k8s/flannel: 111 s
 - k8s/pause: 2 s

 To get k8s up and running from scratch: 2194 s, 36m 34s
 All images time: 2754 s, 45m 54s


 ## 0.4.9
 - resin/rpi-raspbian: 
 - luxas/raspbian: 131 s (without resin pull)
 - luxas/alpine: 43 s
 - luxas/go: 1151 s (+godep, mercurial)
 - k8s/build: 891 s
 - k8s/hyperkube: 183 s
 - k8s/etcd: 13 s
 - k8s/flannel: 107 s
 - k8s/pause: 1 s
 - k8s/exechealthz: 3 s
 - k8s/skydns: 3 s 
 - k8s/kube2sky: 4 s 

 To get all k8s up and running from scratch: 2530 s, 42m 10s