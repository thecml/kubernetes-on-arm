# README FOR THE SD CARD MAKER

**sdcard/write.sh**

Example use: 

```
buildSDCard.sh [disc] [machine] [distro] [middleware] [middleware-script] [middleware-parameters]
buildSDCard.sh /dev/sdb rpi archlinux luxcloud master pimaster
```

This folder contains these files and folders: 

- **machine**: A folder with different types of boards
 - e. g. *rpi*: For the Raspberry Pi
     - `mksdcard.sh`: This script will be called by buildSDCard
     - `files`: All files in this directory will be copied to `tmp` during sd card creation
- **os**: A folder with different types of operating systems
 - e. g. *archlinux*: Arch Linux ARM
     - `mksdcard.sh`: This script will be called by buildSDCard
     - `files`: All files in this directory will be copied to `tmp` during sd card creation
- **middleware**: Optional set of config files that will be copied over to the sd card
 - e. g. *luxcloud*: For the luxcloud project
     - e. g. `master.sh`: A script for the middleware. Defaults to `mksdcard.sh`, but can be overwritten by [middleware-script]
     - `files`: All files in this directory will be copied to `tmp` during sd card creation