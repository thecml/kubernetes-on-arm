### Build Kubernetes for ARM on an amd64 machine. Magic!

This has already been merged to Kubernetes mainline in: [#19769](https://github.com/kubernetes/kubernetes/pull/19769)

How to use this `Dockerfile`:
```console
$ cd scripts/build-k8s-on-amd64
$ docker build -t build-k8s-on-amd64 .
$ docker run --name=build-k8s-on-amd64 build-k8s-on-amd64 true
$ docker cp build-k8s-on-amd64:/output .
```
