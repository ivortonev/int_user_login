#!/bin/bash

CMD_MKTEMP="/usr/bin/mktemp -d"
WKS_DIR="/opt/int_user_login/tmp/"

cd $WKS_DIR

TEMPDIR=`$CMD_MKTEMP`

for i in adlog-* ; do
	USER=`cat $i | cut -f 5- -d " " | jq -r .TargetUserName`
	if [[ "$USER" =~ [$] ]]; then
		rm -f $i
		continue
	fi
	IP=`cat $i | cut -f 5- -d " " | jq -r .IpAddress`
	SZIP=${#IP}
	if [[ "$SZIP" -lt 8 ]]; then
		rm -f $i
		continue
	fi
	echo "$USER:$IP" >> $TEMPDIR/login_sources
	rm -f $i
done

sort -n $TEMPDIR/login_sources | uniq >> $TEMPDIR/login_sources.ok
