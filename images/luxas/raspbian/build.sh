cd "$( dirname "${BASH_SOURCE[0]}" )"

# Build it
docker build -t luxas/raspbian-build .

# Flatten that image
../../../utils/flatten-image/flatten-image.sh luxas/raspbian-build luxas/raspbian



# docker rmi luxas/raspbian-build