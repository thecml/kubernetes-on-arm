## README FOR THE IMAGES

They follow these conventions:

- **Directory name**: Images are named after their path. Example: in `images/**luxas/alpine**/build.sh` the image name should be `luxas/alpine`
- **build.sh**: That script should build the docker image.
- **Dockerfile**: Of course, builds the docker image.
- **inbuild.sh**: If there are too much commands in the Dockerfile, put the script in the `inbuild.sh` and call it from the Dockerfile
- **mkimage.sh**: Builds an base image.
- **onstart.sh**: The script, which is called when the container starts, e. g. starting a gulp thread or a http server