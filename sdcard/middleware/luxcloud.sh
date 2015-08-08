domiddleware(){
	# cd to sdcard/middleware
	cd "$( dirname "${BASH_SOURCE[0]}" )"

	cp ../../installation/install.sh $ROOT/root

	mv $ROOT/root/install.sh $ROOT/root/install-luxcloud

	chmod +x $ROOT/root/install-luxcloud


	cp ../../installation/shortcuts.sh $ROOT/etc/profile.d/
}