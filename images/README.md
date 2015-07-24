## README FOR THE IMAGES ##

They follow these conventions:

- **Directory name**: Should be the same as the docker image name plus the luxas prefix. Example: the nodejs directory should be built as `luxas/nodejs`
- **build.sh**: That script should build the docker image. Should be called from the host. Is called by the Makefile
- **Makefile**: Is on the top of image dirs. Use `make` or `make alpine` to build things.
- **Dockerfile**: Of course, builds the docker image.
- **inbuild.sh**: If there are much commands, put the script in the `inbuild.sh` and call it from the Dockerfile
- **prebuild.sh**: Called by `build.sh`, before the docker build is called
- **Extra files**: Extra help scipts or config files can be present in the directory
- **mkimage.sh**: Builds an base image.