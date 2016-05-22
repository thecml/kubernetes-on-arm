# Kubernetes for multiple platforms

**Author**: Lucas Käldström ([@luxas](https://github.com/luxas))

**Status** (14/05/2016): Most parts are already implemented; still there's room for improvement


## Abstract

Kubernetes is written in Go, and Go supports multiple platforms (`linux/amd64`, `linux/arm`, `windows/amd64`, and so on).
Docker and rkt are also written in Go, and it's possible to use docker on various platforms already.
When it's possible to run docker containers on a specific architecture, people also want to use Kubernetes to manage the containers.

We obviously want Kubernetes to run on as many platforms as possible.
This is a proposal that explains how we should do to achieve a cross-platform system.

### Motivation

## Implementation

## Proposed platforms and history

The default, and the currently only supported platform is obviously `linux/amd64`.
The proposed architectures are `linux/arm`, `linux/arm64` and `linux/ppc64le`.

32-bit ARM (`linux/arm`) was the first platform Kubernetes was ported to, and luxas' project [`Kubernetes on ARM`](https://github.com/luxas/kubernetes-on-arm) (released on Github 31/09/2015)
served as a (unofficial) way of running Kubernetes on ARM devices.
The 30th of November 2015, a tracking issue about making Kubernetes run on ARM was opened: [#17981](https://github.com/kubernetes/kubernetes/issues/17981). It later shifted focus to how to make Kubernetes a more platform-agnostic system.

The 27th of April 2016, Kubernetes `v1.3.0-alpha.3` was released, and became the first release that was able to run the [docker getting started guide](http://kubernetes.io/docs/getting-started-guides/docker/) on `linux/amd64`, `linux/arm`, `linux/arm64` and `linux/ppc64le` without any modification.

If there's interest in running Kubernetes on `linux/s390x` too, it won't require many changes to the source now when we've laid the ground for a multi-platform Kubernetes already.

There is also work going on with porting Kubernetes to Windows (`windows/amd64`). See [this issue](https://github.com/kubernetes/kubernetes/issues/22623) for more details.
However, please note that when porting to a new OS, many more changes have to be implemented in the code compared to porting to another linux architecture.

## Background factors

### Go language details

Go 1.5 introduced many changes. To name a few that are relevant to Kubernetes:
 - C was eliminated from the tree (it was earlier used for the bootstrap runtime).
 - All processors are used by default, which means we should be able to remove [lines like this one](https://github.com/kubernetes/kubernetes/blob/v1.2.0/cmd/kubelet/kubelet.go#L37)
 - The garbage collector became more efficent (but also [confused our latency test](https://github.com/golang/go/issues/14396)).
 - `linux/arm64` and `linux/ppc64le` were added as new ports.
 - The `GO15VENDOREXPERIMENT` was started. We switched from `Godeps/_workspace` to the native `vendor/` in [this PR]().
 - It's not required to pre-build the whole standard library `std` when cross-compliling. [DetailsTODO](#cross-compilation)
 - Builds are approximately twice as slow as earlier. That affects the CI heavily. [Details](#releasing)
 - The native Go DNS resolver will suffice in the most situations. This makes static linking easier.

All release notes for Go 1.5 [are here](https://golang.org/doc/go1.5)

Go 1.6 didn't introduce as many changes as Go 1.5 did, but here are some of note:
 - It should perform a little bit better than Go 1.5
 - `linux/mips64` and `linux/mips64le` were added as ports.
 - Go < 1.6.2 for `ppc64le` had [bugs in it](https://github.com/kubernetes/kubernetes/issues/24922).

All release notes for Go 1.6 [are here](https://golang.org/doc/go1.6)

In Kubernetes 1.2, the only supported go version was `1.4.2`, so `linux/arm` was the only possible extra architecture: [#19769](https://github.com/kubernetes/kubernetes/pull/19769).
In Kubernetes 1.3, [we upgraded to `go1.6.2`](https://github.com/kubernetes/kubernetes/pull/25051), so now it's possible to build Kubernetes for even more multiple architectures [#ARM64num](https://github.com/kubernetes/kubernetes/pull/19769).

#### The `sync/atomic` bug on 32-bit platforms

From https://golang.org/pkg/sync/atomic/#pkg-note-BUG:
> On both ARM and x86-32, it is the caller's responsibility to arrange for 64-bit alignment of 64-bit words accessed atomically. The first word in a global variable or in an allocated struct or slice can be relied upon to be 64-bit aligned.

`etcd` have had [issues](https://github.com/coreos/etcd/issues/2308) with this. See [how to fix it here](https://github.com/coreos/etcd/pull/3249)

```go
// Code example here!
```

This means that all structs should keep all `int64` and `uint64` fields at the top of the struct to be safe.
The bug affects `32-bit` platforms when a `(u)int64` field is accessed by `atomic.StoreInt64`, `atomic.LoadInt64` or similar.
It would be great to write a tool that checks so all `atomic` accessed fields are aligned at the top of the struct, but it's hard: [coreos/etcd#5027](https://github.com/coreos/etcd/issues/5027)

### Multi-platform work by docker

#### Compiling Docker

Since `docker-1.11.0`, there are `Dockerfiles` for building docker for `armhf` (`ARMv7`), `aarch64` (`arm64`), `ppc64le` and `s390x`.
This makes it possible to build `docker` for the architectures above **when running on that platform** (cross-build isn't working in this case)

In some cases, guys like [`Hypriot`](http://blog.hypriot.org) provide prebuilt versions of docker for other architectures. 
Otherwise, you have to build docker from source, and distribute them by yourself

We should work with the Docker team towards automatically releasing Docker binaries and `.deb` packages for every platform on every release. 

#### Multi-platform Docker images

Here's a good article about how the "manifest list" in the Docker image [manifest spec v2](https://github.com/docker/distribution/pull/1068) works: [A step towards multi-platform Docker images](https://integratedcode.us/2016/04/22/a-step-towards-multi-platform-docker-images/)

A short summary: A manifest list is a list of Docker images with a single name (e.g. `busybox`), that holds layers for multiple platforms _when it's stored in a registry_. 
When the image is pulled by a client (`docker pull busybox`), only layers for the target platforms are downloaded. 
Right now we have to write `${ARCH}/busybox` instead, but that leads to extra scripting and unnecessary logic.

When this is working, it's a perfect fit for `hyperkube` images and the like, but we're quite far away from that right now.
See [image naming](#image-naming) for details how we workaround this for the time being.

## Cross-compilation

## Prebuilding the standard library (`std`)

A great blog post [that is describing this](https://medium.com/@rakyll/go-1-5-cross-compilation-488092ba44ec#.5jcd0owem) 

Before Go 1.5, the whole standard library had to be compiled for **all** platforms _might_ be used, and that was a quite slow process:

```console
# From build/build-image/cross/Dockerfile when we used Go 1.4
$ cd /usr/src/go/src && for platform in ${KUBE_CROSSPLATFORMS}; do GOOS=${platform%/*} GOARCH=${platform##*/} ./make.bash --no-clean; done
```

with Go 1.5+, that isn't required, as go will automatically compile the part of the standard library that is used by the code that is being compiled, _and throw it away_.
If you cross-compile multiple times, go will build parts of `std`, throw it away, build again, throw that away and so on.

There is a way of prebuilding the standard library with Go 1.5+ too:

```console
# From build/build-image/cross/Dockerfile when we're using Go 1.5+
$ for platform in ${KUBE_CROSSPLATFORMS}; do GOOS=${platform%/*} GOARCH=${platform##*/} go install std; done
```

### Static cross-compilation

Static compilation with Go 1.5+ is dead easy:

```go
// main.go
package main
import "fmt"
func main() {
    fmt.Println("Hello Kubernetes!")
}
```
```console
$ go build main.go
$ file main
main: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped
$ GOOS=linux GOARCH=arm go build main.go
$ file main
main: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, not stripped
```

The only thing you have to do is change the `GOARCH` and `GOOS` variables. Here's a list of valid values for [GOARCH/GOOS](https://golang.org/doc/install/source#environment)

#### Static compilation with `net`

Consider this:

```go
// main-with-net.go
package main
import (
	"net"
	"fmt"
)
func main() {             
	fmt.Println(net.ParseIP("10.0.0.10").String())
}
```
```console
$ go build main-with-net.go
$ file main-with-net
main-with-net: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, not stripped
$ GOOS=linux GOARCH=arm go build main-with-net.go
$ file main-with-net
main-with-net: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, not stripped
```

Wait, what? Just because we included `net` from the `std` package, the binary defaults to being dynamically linked when target platform == host platform?
Yes, let's take a look at `go env` to get a clue why this happens:

```console
$ go env
GOARCH="amd64"
GOHOSTARCH="amd64"
GOHOSTOS="linux"
GOOS="linux"
GOPATH="/go"
GOROOT="/usr/local/go"
GO15VENDOREXPERIMENT="1"
CC="gcc"
CXX="g++"
CGO_ENABLED="1"
```

See the `CGO_ENABLED=1` at the end? That's where compilation and cross-compilation differs. By default, it will compile statically if no `cgo` code is involved. `net` is one of the packages that prefers `cgo`, but doesn't depend on them. When cross-compiling, `CGO_ENABLED` is set to `0` by default.

To always be on the sure side, run this when compiling statically:

```console
$ CGO_ENABLED=0 go build -a -installsuffix cgo main-with-net.go
$ file main-with-net
main-with-net: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped
```
See [this threadTODO]() for more details.

### Dynamic cross-compilation

In order to dynamically compile a go binary with `cgo`, we need `gcc` installed at build time.

The only Kubernetes binary that is using C code is the `kubelet`, or in fact `cAdvisor` on which `kubelet` depends. The same counts for `hyperkube`, which depends on `kubelet`.

Obviously, the normal `x86_64-linux-gnu` can't compile `arm` binaries, so we have to install gcc cross-compilers for every platform.

We do this in the [`kube-cross`](https://github.com/kubernetes/kubernetes/blob/master/build/build-image/cross/Dockerfile) image,
and depend on the [`emdebian.org` repository](https://wiki.debian.org/CrossToolchains), which isn't ideal.
In the future, we should consider using the latest `gcc` cross-compiler packages from the `ubuntu` main repositories.

Here's an example when cross-compiling plain C code:
```c
// main.c
#include <stdio.h>
main()
{
  printf("Hello world\n");
}
```
```console
$ arm-linux-gnueabi-gcc -o main-c main.c
$ file main-c
main-c: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.3, for GNU/Linux 2.6.32, BuildID[sha1]=00e8a3f0cffb900ca9a56cb2d866636e459b376d, not stripped
```

And here's an example when cross-compiling `go` and `c`:
```go
// main-cgo.go
package main
/*
#include <stdlib.h>
*/
import "C"
import "fmt"
func main() {
	fmt.Println(int(C.random()))
}
```
```console
$ CGO_ENABLED=1 CC=arm-linux-gnueabi-gcc GOOS=linux GOARCH=arm go build main-cgo.go
$ file main-cgo
./main-cgo: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.3, for GNU/Linux 2.6.32, BuildID[sha1]=25560ead9a04bf26314e5f82c8f6f3ed65597c90, not stripped
```

The bad thing with dynamic compilation is that it adds an unnecessary dependency on `glibc` _at runtime_.

### Static compilation with CGO code

Lastly, it's even possible to cross-compile `cgo` code statically:

```console
$ CGO_ENABLED=1 CC=arm-linux-gnueabi-gcc GOOS=linux GOARCH=arm go build --ldflags '-extldflags "-static"' main-cgo.go
$ file main-cgo
./main-cgo: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, for GNU/Linux 2.6.32, BuildID[sha1]=d596d07a92c478770c3306843e29d9a7cebbd52f, not stripped
```

This is especially useful if we want to include the binary in a container. 
If the binary is statically compiled, we may use `busybox` or even `scratch` as the base image.
This should be the preferred way of compiling binaries that strictly require C code to be a part of it.

#### GOARM

ARM contains three relevant variants: `ARMv5` (soft-float), `ARMv6` (both soft and hard-float) and `ARMv7` (hard-float; the most common one)
`armel` means that the processor is soft-float, `armhf` is hard-float. The Raspberry Pi 1 is quite special, it's processor is `ARMv6` hard-float.
`ARMv5` binaries can run on `ARMv6` devices, but not vice versa. The same for `ARMv6` and `ARMv7`.
GCC packages for ARM come in two flavors: `armel` and `armhf`. Here we encounter a problem: the `armel` gcc package is `ARMv5` and the `armhf` package is `ARMv7` 
Since we want support for the Raspberry Pi 1, we have to use `armel` for linking the `cgo` code, otherwise it won't work. 
The performance difference between `ARMv5` and `ARMv7` is so small anyway, so it doesn't matter.

## Cross-building for linux

After we've cross-compiled some binaries for another architecture, we often want to package it in a docker image.

### Trivial Dockerfile

All `Dockerfile` commands except for `RUN` works without any modification.
Of course, the base image has to be switched to an arch-specific one, but except from that

```Dockerfile
FROM armel/busybox
ENV kubernetes=true
COPY kube-apiserver /usr/local/bin/
CMD ["/usr/local/bin/kube-apiserver"]
```
```console
$ ldd kube-apiserver
kube-apiserver: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, not stripped
$ docker build -t gcr.io/google_containers/kube-apiserver-arm:v1.x.y
TODO
```

### Complex Dockerfile

However, in many cases, `RUN` statements are needed when building the image.
The `RUN` statement invokes `/bin/sh` in the container, but since we're using `armel/debian` for example as the base image, `/bin/sh` is an ARM binary and can't execute on a `amd64` host.

#### QEMU to the rescue

Here's a way to run ARM Docker images on an amd64 host by using `qemu`:
```console
# Register other architectures' magic numbers in the binfmt_misc kernel module, so it's possible to run foreign binaries
$ docker run --rm --privileged multiarch/qemu-user-static:register --reset
# Download qemu 2.5.0
$ curl -sSL https://github.com/multiarch/qemu-user-static/releases/download/v2.5.0/x86_64_qemu-arm-static.tar.xz | tar -xJ
# Run a foreign docker image, and inject the amd64 qemu binary for translating all syscalls
$ docker run -it -v $(pwd)/qemu-arm-static:/usr/bin/qemu-arm-static armel/busybox /bin/sh

# Now we're inside an ARM container although we're running on an amd64 host
$ uname -a
Linux 0a7da80f1665 4.2.0-25-generic #30-Ubuntu SMP Mon Jan 18 12:31:50 UTC 2016 armv7l GNU/Linux
```

Here, `binfmt_misc`, a linux module, registered the "magic numbers" for other architectures, and whenever the kernel should execute a binary, it'll check if it's foreign, and in that case prepend the call with `/usr/bin/qemu-(arm|aarch64|ppc64le)-static`.
`/usr/bin/qemu-arm-static` is an `amd64` binary that is statically linked and translates all syscalls it gets from the ARM binary (in this example `/bin/sh`) to `amd64` ones.

The multiarch guys have done a great job here, you may find the source for the image and other documentation at [Github](https://github.com/multiarch)

## Code changes required

### The pause image

The `pause` is used for connecting containers into Pods. It's a binary that just sleeps forever. 

`kubelet` has the `--pod-infra-container-image` option, and that option has been used when running Kubernetes on other platforms, because obviously the `pause-amd64` image can't run on `arm` hosts for example.

### Exposing information



### Dependencies


## Conditional build tags


## Releasing

### Image naming

### Client binaries


## Running Kubernetes




## Addons

### DNS

### Heapster

### Ingress

### Registry

### Logging


## Conflicts

### How are multiple platforms supported?




Kubernetes is a great piece of software and a great platform for learning how distributed computing works.
And it will be even easier and cheaper for people to try Kubernetes out on Raspberry Pi's

As Brendan Burns noted on Twitter, Kubernetes cluster of Raspberry Pis is the new ["Hello World"](https://twitter.com/brendandburns/status/697499559539384320	) of cloud computing




