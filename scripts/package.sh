#!/bin/bash

main() {
	cd "$( dirname "${BASH_SOURCE[0]}" )"/..

	OUT=release/latest

	source scripts/images.sh

	if [[ -d $OUT ]]; then
		source $OUT/meta.sh

		mv release/{latest,$BUILD_DATE}
	fi


	mkdir -p $OUT

	echo "Saving docker images: "
	docker save ${IMAGES[@]} | gzip > $OUT/images.tar.gz

	echo "Bundling binaries: "
	cd /etc/kubernetes/binaries/
	tar -czf $OUT/binaries.tar.gz *
	cd -

	cp /etc/kubernetes/binaries/kubectl $OUT

	echo "BUILD_DATE=$(date +%d%m%y_%H%M)" >> $OUT/meta.sh

	if [[ -f /etc/kubernetes/SDCard_metadata.conf ]]; then
		source /etc/kubernetes/SDCard_metadata.conf
		echo "REPO_COMMIT=$K8S_ON_ARM_COMMIT" >> $OUT/meta.sh
	fi

	if [[ -f /etc/kubernetes/source/version ]]; then
		source /etc/kubernetes/source/version
		echo "REPO_VERSION=$VERSION" >> $OUT/meta.sh
	fi

	echo "Output in $(pwd)/$OUT: "
	ls -lh $OUT

	echo "Metadata file: $OUT/meta.sh"
	cat $OUT/meta.sh


	# Took ~4 minutes
}

time main