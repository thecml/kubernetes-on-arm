### README FOR THE IMAGES

They follow these conventions:

- **Directory name**: Images are named after their path. Example: in `images/**luxas/alpine**/` the image name should be `luxas/alpine`
- **build.sh**: The script that builds the Docker image. Optional. Defaults to `docker build -t $DIRECTORY_PATH $DIRECTORY_PATH`
- **Dockerfile**: Of course, builds the docker image.
- **inbuild.sh**: If e.g. bash features is required in the `Dockerfile` or there are many commands, this file is very handy. `COPIED` in to the `Dockerfile`.
- **mkimage.sh**: Builds an base image.
- **onstart.sh**: A script which is called when the image starts
- **deps**: Other images an image depends on.