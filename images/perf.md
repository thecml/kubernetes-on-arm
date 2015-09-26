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
 - luxas/raspbian: 131 s (without resin pull)
 - luxas/go: 