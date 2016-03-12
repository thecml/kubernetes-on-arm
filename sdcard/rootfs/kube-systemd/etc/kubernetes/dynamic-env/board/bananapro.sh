# This command is run by kube-config when doing "kube-config install"
board_post_install(){

    # Customized commands just for banana pro
    # No commands for now
    echo "Banana Pro setup completed"
}

# This code will never be called. It's just kept for reference
get_uboot_bin_file(){
    TMPDIR=$(mktemp -d /tmp/bananapro-uboot.XXXXX)

    cat > $TMPDIR/Dockerfile <<EOF
FROM resin/rpi-raspbian:jessie

# Run gpg twice, so it works
RUN gpg --recv-keys 24BFF712 && gpg --recv-keys 24BFF712    && \
    gpg --armor --export 24BFF712 | apt-key add -           && \
    echo "deb http://dl.bananian.org/packages/ jessie main" > /etc/apt/sources.list.d/bananian.list && \
    apt-get update && mkdir -p /bananian/uboot              && \
    cd /bananian && apt-get download u-boot-bananian        && \
    dpkg -x u-boot-bananian_15.08.02_armhf.deb uboot
EOF
    time docker build -t build/get-bananapro-uboot $TMPDIR

    CID=$(docker run -d build/get-bananapro-uboot /bin/bash)
    docker cp $CID:/bananian/uboot/usr/lib/u-boot-sunxi-with-spl.bin /usr/lib

    echo "Done. The uboot file is in /usr/lib"
    ls -l /usr/lib/u-boot-sunxi-with-spl.bin

}