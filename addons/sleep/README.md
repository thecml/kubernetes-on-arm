### Just two pods for testing

If you want to test out some kubernetes settings like DNS, this addon is very handy.
Starts up two containers, from luxas/raspbian and luxas/alpine and they both sleep in 1 hour and restarts.

Example use:
```
kubectl exec -it alpine-sleep /bin/sh

kubectl exec -it raspbian-sleep /bin/bash

kubectl exec -it alpine-sleep -- nslookup kubernetes.default.svc.cluster.local
```