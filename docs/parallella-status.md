# Unfortunately Parallella isn't a good choice at the moment

It is possible to write a sd card for it, but it's a painfully slow system.

`sdcard/write.sh parallella archlinux kube-systemd`

Notify me if there is newer versions of these. This is the current configuration.
Kernel: 3.14
Docker storage driver: devicemapper
Systemd: 226 -> `docker -d --exec-opt native.cgroupdriver=cgroupfs`

Docker building and running is so exceptionally slow that I can't understand it.
Example: the pause image.
The pause binary is 227 kB.
```
FROM scratch
COPY pause /
ENTRYPOINT ["/pause"]
``` 

This build takes 1 second on a Raspberry Pi 2.
It takes 200 seconds to build on a Parallella!


Please give suggestions what I could do to make it faster!

Follow the thread [here](https://github.com/parallella/parallella-linux/issues/8)