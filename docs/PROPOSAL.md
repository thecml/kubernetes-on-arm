# Kubernetes for multiple platforms

**Author**: Lucas Käldström ([@luxas](https://github.com/luxas))

**Status** (14/05/2016): Most parts are already implemented; still there's room for improvement


## Abstract

Kubernetes is written in Go, and Go supports multiple platforms (`linux/amd64`, `linux/arm`, `windows/amd64`, and so on).
Docker is also written in Go, and it's possible to use Docker on various platforms already.
When it's possible to run docker containers on a specific architecture, folks also want to use Kubernetes to manage the containers.

We obviously want Kubernetes to run on as many platforms as possible.
This is a proposal that explains how we should do to achieve a cross-platform system.

## Implementation

## Proposed platforms and history

The default platform is obviously `linux/amd64`.
The proposed architectures are `linux/arm`, `linux/arm64` and `linux/ppc64le`.

ARM was the first platform Kubernetes was ported to, and my project [`Kubernetes on ARM`](https://github.com/luxas/kubernetes-on-arm) (released on Github 31/09/2015)
served as a (unofficial) way of running Kubernetes on ARM devices (primarily the Raspberry Pi 2).
Then, a tracking issue about making Kubernetes run on ARM was opened 30/11/2015: [#17981](https://github.com/kubernetes/kubernetes/issues/17981)

The 27th April 2016, Kubernetes `v1.3.0-alpha.3` was released, and became the first release that was able to run the [docker getting started guide](http://kubernetes.io/docs/getting-started-guides/docker/) on `linux/amd64`, `linux/arm`, `linux/arm64` and `linux/ppc64le` without any modification.

Additionally, if there's interest in running Kubernetes on `linux/s390x` too, it won't require many changes to the source now when we've laid the ground already.

There is also work going on with porting Kubernetes to Windows (`windows/amd64`). See [this issue](https://github.com/kubernetes/kubernetes/issues/22623) for more details.
However, please note that when porting to another OS, many more changes have to be implemented in the code compared to porting to another linux architecture.

## Background factors

### Go language details

Go 1.5 introduced many changes. To name a few that is relevant to Kubernetes:
 - C was eliminated from the tree (it was earlier used for the bootstrap runtime).
 - All processors are used by default, which means we should be able to remove [lines like this one](https://github.com/kubernetes/kubernetes/blob/v1.2.0/cmd/kubelet/kubelet.go#L37)
 - The garbage collector became more efficent (but also [confused our latency test](https://github.com/golang/go/issues/14396)).
 - `linux/arm64` and `linux/ppc64le` were added as ports.
 - The `GO15VENDOREXPERIMENT` was started. We switched from `godep` to native vendor in [this PR]().
 - It's not required to pre-build the whole standard library `std` when cross-compliling. [Details](#cross-compilation)
 - Builds are approximately twice as slow as earlier. That affects the CI heavily. [Details](#releasing)
 - The native Go DNS resolver will suffice in the most situations. This makes static linking easier.
 - All release notes for [go1.5](https://golang.org/doc/go1.5)

Go 1.6 didn't introduce as many changes as go1.5 did, but here are some of note:
 - It should perform a little bit better than go1.5
 - `linux/mips64` and `linux/mips64le` were added as ports.
 - Go < 1.6.2 for `ppc64le` had [bugs in it](https://github.com/kubernetes/kubernetes/issues/24922).
 - All release notes for [go1.6](https://golang.org/doc/go1.6)

In Kubernetes 1.2, the only supported go version was `1.4.2`, so `linux/arm` was the only possible extra architecture: [#19769](https://github.com/kubernetes/kubernetes/pull/19769)
In Kubernetes 1.3, [we upgraded to `go1.6.2`](https://github.com/kubernetes/kubernetes/pull/25051), so now it's possible to build Kubernetes for even more multiple architectures.

#### GOARM

ARM contains three relevant variants: `ARMv5` (soft-float), `ARMv6` (both soft and hard-float) and `ARMv7` (hard-float; the most common one)
`armel` means that the processor is soft-float, `armhf` is hard-float. The Raspberry Pi 1 is quite special, it's processor is `ARMv6` hard-float.
`ARMv5` binaries can run on `ARMv6` devices, but not vice versa. The same for `ARMv6` and `ARMv7`.
GCC packages for ARM come in two flavors: `armel` and `armhf`. Here we encounter a problem: the `armel` gcc package is `ARMv5` and the `armhf` package is `ARMv7` 
Since we want support for the Raspberry Pi 1, we have to use `armel` for linking the `cgo` code, otherwise it won't work. 
The performance difference between `ARMv5` and `ARMv7` is so small anyway, so it doesn't matter.

#### `sync/atomic` 32-bit bug

From https://golang.org/pkg/sync/atomic/#pkg-note-BUG:
> On both ARM and x86-32, it is the caller's responsibility to arrange for 64-bit alignment of 64-bit words accessed atomically. The first word in a global variable or in an allocated struct or slice can be relied upon to be 64-bit aligned.

`etcd` have had [issues](https://github.com/coreos/etcd/issues/2308) with this. See [how to fix it here](https://github.com/coreos/etcd/pull/3249)
This means that all structs should keep all `int64` and `uint64` fields at the top of the struct to be safe.
The bug affects `32-bit` platforms when a `(u)int64` field is accessed by `atomic.StoreInt64`, `atomic.LoadInt64` or similar.
It would be great to write a tool that checks so all `atomic` accessed fields are aligned at the top of the struct, but it's hard: [coreos/etcd#5027](https://github.com/coreos/etcd/issues/5027)

### Multi-platform work by docker

#### Building Docker

Since `docker-1.11.0`, there are `Dockerfiles` for `armhf` (`ARMv7`), `aarch64` (`arm64`), `ppc64le` and `s390x`.
This makes it possible to build `docker` for the architectures above **when running on that platform** (cross-build isn't working)

In some cases, guys like [`Hypriot`](http://blog.hypriot.org) provide prebuilt versions of docker for other architectures. 
Otherwise, one have to build docker from source.

In the future, it would be great to work with the Docker team towards automatically releasing Docker binaries and `.deb` packages for every new release. 

#### Multi-platform Docker images

Here's a good article about how the "manifest list" in the Docker image manifest spec v2 works: https://integratedcode.us/2016/04/22/a-step-towards-multi-platform-docker-images/

A short summary: A manifest list is a list of Docker images with a single name (e.g. `busybox`), that holds layers for multiple platforms. 
When the image is pulled by a client (`docker pull busybox`), only layers for the target platforms are downloaded. 
Right now we have to write `${ARCH}/busybox` instead, but that leads to extra scripting and unnecessary logic.

When this is working, it's a perfect fit for `hyperkube` images and the like, but we're quite far away from that right now.
See [image naming](#image-naming) for details how we workaround this.

## Cross-compilation

## Building the standard library (`std`)

A great blog post [that is describing this](https://medium.com/@rakyll/go-1-5-cross-compilation-488092ba44ec#.5jcd0owem) 

Before go1.5, the whole standard library had to be compiled for **all** platforms that would be used, and that took a while:

```console
# From build/build-image/cross/Dockerfile when we had go1.4
$ cd /usr/src/go/src && for platform in ${KUBE_CROSSPLATFORMS}; do GOOS=${platform%/*} GOARCH=${platform##*/} ./make.bash --no-clean; done
```

with go1.5+, that isn't required, as go will automatically compile the part of the standard library that is used by the code that is being compiled, _and throw it away_.
If you cross-compile multiple times, go will build parts of `std`, throw it away, build again, throw that away and so on.

There is a way of prebuilding the standard library with go1.5+ too:

```console
$ for platform in ${KUBE_CROSSPLATFORMS}; do GOOS=${platform%/*} GOARCH=${platform##*/} go install std; done
```

### Static compilation

Static compilation with go1.5+ is dead easy:

```go
package main
import "fmt"
func main() {
    fmt.Println("Hello Kubernetes!")
}
```
```console
$ GOOS=linux GOARCH=arm go build main.go
$ file main
TODO
```

The only thing you have to do is change the `GOARCH` and `GOOS` variables. Here's a list of valid values for [GOARCH/GOOS](https://golang.org/doc/install/source#environment)

### Dynamic compilation

In order to dynamically compile a go binary with `cgo`, we need `gcc` installed at build time. 
`kubelet` is using `cAdvisor`, which uses some C files, so it has to be compiled with cgo.

Obviously, the normal `amd64` `gcc` can't compile `arm` binaries, so we have to install gcc cross-compilers for every platform.
We do this in the [`kube-cross`](https://github.com/kubernetes/kubernetes/blob/master/build/build-image/cross/Dockerfile) image,
and depend on the [`emdebian.org` repository](https://wiki.debian.org/CrossToolchains), which isn't ideal.
In the future, we should consider changing base image to `ubuntu`, from where we may download the cross-compilers from the main repo.

However, when we've downloaded a full `gcc` installation that's able to compile binaries for another architecture, we may also use `cgo`.

Here's an example when cross-compiling with plain `gcc`:
```c
#include <stdio.h>
main()
{
  printf("Hello world\n");
}
```
```console
$ arm-linux-gnueabi-gcc main.c
$ file main
TODO
```

And here's an example when cross-compiling `go` and `c`:
```go
package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"fmt"
)

func main() {
	fmt.Println(int(C.random()))
}
```
```console
$ CGO_ENABLED=1 CC=arm-linux-gnueabi-gcc GOOS=linux GOARCH=arm go build main.go
$ file main
TODO
```

### Static compilation with CGO code

Lastly, it's even possible to cross-compile `cgo` code statically

```console
$ CGO_ENABLED=1 CC=arm-linux-gnueabi-gcc GOOS=linux GOARCH=arm go build --ldflags '-extldflags "-static"' main.go
$ file main
TODO
```

This is especially useful if we want to include the binary in a container. 
If the binary is statically compiled, we may use `busybox` or even `scratch` as the base image.
The goal should be to be able to compile `kubelet` this way, so we get rid of the dependency on `glibc` libraries at runtime.


## Cross-building

### QEMU




## Code changes required

### The pause image

### Exposing information

### Dependencies





## Releasing

### Image naming

### Client binaries


## Clustering

### Running locally

### Running locally dockerized

### Running docker-multinode


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




