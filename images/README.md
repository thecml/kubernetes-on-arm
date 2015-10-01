# README FOR THE IMAGES

They follow these conventions:

- **Directory name**: Images are named after their path. Example: in `images/**luxas/alpine**/build.sh` the image name should be `luxas/alpine`
- **build.sh**: That script should build the docker image. Should be called from the host. Is called by the Makefile
- **Dockerfile**: Of course, builds the docker image.
- **inbuild.sh**: If there are much commands, put the script in the `inbuild.sh` and call it from the Dockerfile
- **mkimage.sh**: Builds an base image.
- **onstart.sh**: The script, which is called when the container starts, e. g. starting a gulp thread and a http server