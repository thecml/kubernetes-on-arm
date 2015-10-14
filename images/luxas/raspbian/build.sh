cd "$( dirname "${BASH_SOURCE[0]}" )"

# Build it
docker build -t build/raspbian .

# Flatten that image
../../../utils/flatten-image/flatten-image.sh build/raspbian luxas/raspbian

# Clean up our temp image
docker rmi build/raspbian