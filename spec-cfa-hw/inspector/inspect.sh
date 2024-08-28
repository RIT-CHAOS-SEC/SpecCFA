if [ -z "$1" ]; then
	echo "------ "
	echo "ERROR: need path to log directory as input"
	echo "------ "
	echo "Example: "
	echo " ./inspect.sh ../logs/app_baseline"
else
	LOG_PATH=$1

	rm all.cflog
	touch all.cflog 

	for f in $LOG_PATH/*.cflog; do echo "Reading $f"; cat $f >> all.cflog; done
	echo "Done"
	echo "---------------"
	echo "Processing ./all_cflog"
	sed -i "s/\s[0-9]*//g" all.cflog
	sed -i '/^$/d' all.cflog
	echo "Done"
	echo "---------------"
fi