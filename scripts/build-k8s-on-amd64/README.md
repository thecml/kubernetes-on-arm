### Build Kubernetes for ARM on an amd64 machine. Magic!

This has already been merged to Kubernetes mainline in: [#19769](https://github.com/kubernetes/kubernetes/pull/19769)

How to use `build.sh`:
```console
$ # All binaries will end up in ./output
$ # To build binaries:
$ ./build.sh
$ # To build binaries for arm64:
$ ./build.sh arm64
```
