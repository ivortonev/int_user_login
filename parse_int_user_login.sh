#!/bin/bash

CMD_MKTEMP="/usr/bin/mktemp -d"
CMD_CAT="/usr/bin/cat"
CMD_DIG="/usr/bin/dig"
CMD_CUT="/usr/bin/cut"
CMD_GREP="/usr/bin/grep"
CMD_YUM="/usr/bin/yum"
CMD_ECHO="/usr/bin/echo"
CMD_MKDIR="/usr/bin/mkdir"
CMD_CHMOD="/usr/bin/chmod"
CMD_RM="/usr/bin/rm"
CMD_JQ="/usr/bin/jq"
CMD_SORT="/usr/bin/sort"
CMD_UNIQ="/usr/bin/uniq"
CMD_USER_DATA="user_data.php"
CMD_PHP="/usr/bin/php"

WKS_DIR="/opt/int_user_login/tmp"
PHP_DIR="/opt/int_user_login/php"

cd $WKS_DIR

TEMP_DIR=`$CMD_MKTEMP`

for i in adlog-* ; do
	USER=`$CMD_CAT $i | $CMD_CUT -f 5- -d " " | $CMD_JQ -r .TargetUserName`
	if [[ "$USER" =~ [$] ]]; then
		$CMD_RM -f $i
		continue
	fi
	IP=`$CMD_CAT $i | $CMD_CUT -f 5- -d " " | $CMD_JQ -r .IpAddress`
	SZIP=${#IP}
	if [[ "$SZIP" -lt 8 ]]; then
		$CMD_RM -f $i
		continue
	fi
	$CMD_ECHO "$USER:$IP" >> $TEMP_DIR/login_sources
	$CMD_RM -f $i
done

$CMD_SORT -n $TEMP_DIR/login_sources | $CMD_UNIQ >> $TEMP_DIR/login_sources.uniq

cd $PHP_DIR
$PHP_DIR/$CMD_PHP $TEMP_DIR/login_sources.uniq

$CMD_RM -rf $TEMP_DIR
