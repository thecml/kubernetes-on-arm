# Docker on ARM

This document collects findings to consider when running Docker on ARM.

Please keep in mind that this is intended as a collection of important / useful things that are different when running containers on different processor architectures. 
It's most certainly not final and if you have some objections, please create a pull-request :-)

## Architecture does matter

Event if many modern software stacks encapsulate differences between architectures and you can easily 
run a application based on Java as well as one based on NodeJS on a PC (x86) and on a RaspberryPi (ARM), the underlying 
components still are dependend on the architecture.

So when you build your docker image for your application, you most certainly create a platform dependend image as you either build 
upon on that already has specific packages included or you include such in your docker file.

An example to this would be the baseimage for a nodejs application. For x86 you would for example use `FROM node:0.12` to build your docker image.
But that wouldn't run on a RaspberryPi as it's binary incompatible.You need to use a ARM compatible base image. `FROM hypriot/rpi-node` would be such one.

Same goes for Java. Instead of the standard `FROM java:openjdk-8-jre` you could for example use `FROM oysteinjakobsen/armv7-oracle-java8`.


