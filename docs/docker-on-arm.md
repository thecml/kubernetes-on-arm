# Running 64-bit docker images on ARM, why doesn't it work?

Imagine this:
```
$ docker run -it ubuntu /bin/bash

exec format error
Error response from daemon: Cannot start container 977d87157e: [8] System error: exec format error
```

What is the problem?
I just want to run ubuntu on my Pi.

## Explanation

Docker is said run on everywhere, but that is not the case.
Docker "officially" supports just amd64 machines.
So even if docker is built on a lot of platforms, nearly every docker image is amd64
That makes nearly whole Docker Hub unavailable for ones that run things on ARM, which is 32-bit

In an ideal world, docker images could run on every machine regardless of platform.

Think of it like this:

 - One 64-bit user makes a nginx image
 - In the Dockerfile, a 64-bit nginx binary is downloaded from nginx website, to /usr/bin/nginx
 - The user builds the docker image.

If I then downloaded this image and tried to run it, **I wouldn't work, because of that 64-bit binary**
So, therefore, **docker exits before it even starts the image.**

It's quite logical, you can't run 64-bit Windows on a Pi either.

IMO, this error message could be much more user-friendly

## What can we do then?

But, there are images on Docker Hub, which works on ARM (in that case, they're often built on ARM too)
Some cool images for ARM:

 - Hypriot: https://hub.docker.com/u/hypriot
 - Armbuild: https://hub.docker.com/u/armbuild
 - and myself: https://hub.docker.com/u/luxas

One may also do `docker search armhf` or `docker search rpi`

If you just want to start hacking and test it out, this image is handy:
```
docker run -it luxas/raspbian /bin/bash
```

Check which architecture an image has
```
$ docker inspect kubernetesonarm/pause

{
	...

	"Architecture": "arm",
    "Os": "linux",
    ...
}

$ docker inspect kubernetesonarm/pause | grep "Architecture"

"Architecture": "arm",
```

## The good news

In some cases it's quite easy to convert `Dockerfiles` to ARM.

Consider this dummy Dockerfile:
```
FROM debian:jessie

RUN apt-get install mysql

...
```

If you're really lucky, the only thing you need to do is change the `FROM` directive to a corresponding ARM alternative. 
 - `debian` and `ubuntu` is often comparable to `luxas/raspbian` or `resin/rpi-raspbian`
 - `ubuntu` is represented by `umiddelb/armhf-ubuntu`. I haven't tried it, but it seemed good.
 - `busybox` and `alpine` is comparable to `luxas/alpine`.

Good luck!