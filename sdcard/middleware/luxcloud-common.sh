
# Setup variables
BINDIR=$ROOT/usr/local/bin
LUXDIR=$BINDIR/luxcloud
CURRENT_INSTALLATION_DIR="../../installation"

docommon(){
	# cd to sdcard/middleware
	cd "$( dirname "${BASH_SOURCE[0]}" )"

	# Make the directory for the scripts
	mkdir -p $LUXDIR

	# Copy install.sh to the luxcloud dir
	cp $CURRENT_INSTALLATION_DIR/install.sh $LUXDIR

	# And the wrapper to the bin dir
	cp $CURRENT_INSTALLATION_DIR/luxcloud.sh $BINDIR

	# Rename luxcloud.sh to luxcloud
	mv $BINDIR/luxcloud.sh $BINDIR/luxcloud

	# Remember when we built the sd card
	echo -e "SD_CARD_BUILD_DATE=\"$(date +%d%m%y)\" \n" > $LUXDIR/config.sh

	# Specify hostname of the middleware parameter
	echo -e "HOSTNAME=\"$MIDDLEWARE_PARAM\" \n" >> $LUXDIR/config.sh

	# Make everything executable
	chmod +x $LUXDIR/*
	chmod +x $BINDIR/luxcloud

	# Make shortcuts
	cp $CURRENT_INSTALLATION_DIR/shortcuts.sh $ROOT/etc/profile.d/
}