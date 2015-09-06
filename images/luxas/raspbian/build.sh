cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

# Build it
docker build -t build/raspbian .

# Flatten that image
../../../utils/flatten-image/flatten-image.sh build/raspbian luxas/raspbian:$(LUX_VERSION)