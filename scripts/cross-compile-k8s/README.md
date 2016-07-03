### Build Kubernetes for (ARM|ARM64|PowerPC64le) on an amd64 machine. Magic!

This has already been merged to Kubernetes mainline.
This code nowadays lives in: https://github.com/kubernetes/kubernetes/tree/master/cluster/images
See this issue for more info: [#17981](https://github.com/kubernetes/kubernetes/issues/17981)

This script cross-compiles `etcd`, `flannel` and `kubernetes`.

How to use `build.sh`:
```console
$ # All binaries will end up in ./output/${ARCH}
$ # Example commands:
$ make ARCH=arm
$ make ARCH=arm64
$ make ARCH=ppc64le
```
