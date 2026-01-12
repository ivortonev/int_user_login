#!/bin/bash

CMD_CAT="/usr/bin/cat"
CMD_DIG="/usr/bin/dig"
CMD_CUT="/usr/bin/cut"
CMD_GREP="/usr/bin/grep"
CMD_YUM="/usr/bin/yum"
CMD_ECHO="/usr/bin/echo"
CMD_MKDIR="/usr/bin/mkdir"
CMD_CHMOD="/usr/bin/chmod"
CMD_CURL="/usr/bin/curl"
CMD_MV="/usr/bin/mv"
CMD_SYSTEMCTL="/usr/bin/systemctl"
CMD_CP="/usr/bin/cp"
CMD_CHOWN="/usr/bin/chown"
CMD_PWGEN="/usr/bin/pwgen -c -n -s 32 1"
CMD_MYSQLADMIN="/usr/bin/mysqladmin"
CMD_MYSQL="/usr/bin/mysql"
CMD_RM="/usr/bin/rm"
CMD_SED="/usr/bin/sed"

PRJ_DIR="/opt/int_user_login"
BIN_DIR="$PRJ_DIR/bin"
PHP_DIR="$PRJ_DIR/php"
TMP_DIR="$PRJ_DIR/tmp"
SNG_DIR="/etc/syslog-ng"
WEB_DIR="/usr/share/nginx/html"

# Installing pre-reqs
$CMD_YUM clean all
$CMD_YUM update -y
$CMD_YUM install -y epel-release 
$CMD_YUM clean all
$CMD_YUM update
$CMD_YUM install -y nginx bind-utils php-common php-cli php-fpm php-process php-pdo php-mysqlnd php-mbstring php-intl php-pecl-zip php-xml php-gd jq syslog-ng mariadb-common mariadb-client-utils mariadb mariadb-server-utils mariadb-server

INSTALL_SCRIPT=`$CMD_DIG int_user_login_sh.tonev.pro.br TXT +short | $CMD_CUT -f 2 -d "\""`
UPDATE_SCRIPT=`$CMD_DIG int_user_login_up.tonev.pro.br TXT +short | $CMD_CUT -f 2 -d "\""`
GITHUB_VERSION=`$CMD_DIG int_user_login_ver.tonev.pro.br TXT +short | $CMD_CUT -f 2 -d "\""`

if [ -f "$PRJ_DIR/version" ]; then
	LOCAL_VERSION=`$CMD_CAT $PRJ_DIR/version`
else
	LOCAL_VERSION="0.0.0"
fi

#if [ $LOCAL_VERSION != $GITHUB_VERSION ]; then
#	$CMD_ECHO "Local version: $LOCAL_VERSION"
#	$CMD_ECHO "github version: $GITHUB_VERSION"
#	$CMD_ECHO "Please run update script as root"
#	$CMD_ECHO "curl $UPDATE_SCRIPT | bash"
#	exit 1;
#fi

MYSQL_ROOT_PASSWORD=`$CMD_PWGEN`
MYSQL_USER_PASSWORD=`$CMD_PWGEN`

$CMD_ECHO -n "Please choose a username for the SQL database: " 
read USER_LOGIN

$CMD_ECHO -n "Please choose a name for the SQL database: "
read MYSQL_DB_NAME

$CMD_MV -f $SNG_DIR/syslog-ng.conf $SNG_DIR/syslog-ng.conf.orig
$CMD_CURL -o $SNG_DIR/syslog-ng.conf		https://raw.githubusercontent.com/ivortonev/int_user_login/refs/heads/main/syslog-ng.conf
$CMD_CHMOD 644 $SNG_DIR/syslog-ng.conf
$CMD_SYSTEMCTL enable syslog-ng.service nginx.service mariadb.service php-fpm.service
$CMD_SYSTEMCTL stop syslog-ng.service nginx.service mariadb.service php-fpm.service
$CMD_SYSTEMCTL start syslog-ng.service nginx.service mariadb.service php-fpm.service

$CMD_MKDIR -m 755 $PRJ_DIR
$CMD_CURL -o $PRJ_DIR/int_user_login.sql	https://raw.githubusercontent.com/ivortonev/int_user_login/refs/heads/main/int_user_login.sql
$CMD_CURL -o $PRJ_DIR/version			https://raw.githubusercontent.com/ivortonev/int_user_login/refs/heads/main/version
$CMD_CHMOD 600 $PRJ_DIR/int_user_login.sql
$CMD_CHMOD 600 $PRJ_DIR/version

$CMD_MKDIR -m 755 $BIN_DIR
$CMD_CURL -o $BIN_DIR/ingest_int_user_login.sh	https://raw.githubusercontent.com/ivortonev/int_user_login/refs/heads/main/ingest_int_user_login.sh
$CMD_CURL -o $BIN_DIR/parse_int_user_login.sh	https://raw.githubusercontent.com/ivortonev/int_user_login/refs/heads/main/parse_int_user_login.sh
$CMD_CHMOD 755 $BIN_DIR/ingest_int_user_login.sh
$CMD_CHMOD 700 $BIN_DIR/parse_int_user_login.sh

$CMD_MKDIR -m 700 $PHP_DIR
$CMD_CURL -o $PHP_DIR/conf.php			https://raw.githubusercontent.com/ivortonev/int_user_login/refs/heads/main/conf.php
$CMD_CURL -o $PHP_DIR/expire.php		https://raw.githubusercontent.com/ivortonev/int_user_login/refs/heads/main/expire.php
$CMD_CURL -o $WEB_DIR/user.php			https://raw.githubusercontent.com/ivortonev/int_user_login/refs/heads/main/user.php
$CMD_CURL -o $PHP_DIR/user_data.php		https://raw.githubusercontent.com/ivortonev/int_user_login/refs/heads/main/user_data.php
$CMD_SED -e "s/SQL_USER_LOGIN/$USER_LOGIN/g" $PHP_DIR/conf.php | $CMD_SED -e "s/SQL_USER_PASSWD/$MYSQL_USER_PASSWORD/g" | $CMD_SED -e "s/SQL_DATABASE/$MYSQL_DB_NAME/g" > $PHP_DIR/conf.php.tmp
$CMD_MV -f $PHP_DIR/conf.php.tmp $PHP_DIR/conf.php
$CMD_CP $PHP_DIR/conf.php $WEB_DIR/conf.php
$CMD_CHMOD 600 $PHP_DIR/conf.php
$CMD_CHMOD 640 $PHP_DIR/conf.php
$CMD_CHMOD 600 $PHP_DIR/expire.php
$CMD_CHMOD 640 $WEB_DIR/user.php
$CMD_CHMOD 600 $PHP_DIR/user_data.php
$CMD_CHOWN root:apache $WEB_DIR/conf.php
$CMD_CHOWN root:apache $WEB_DIR/user.php
 
$CMD_MYSQLADMIN password $MYSQL_ROOT_PASSWORD
$CMD_MYSQLADMIN create $MYSQL_DB_NAME

$CMD_ECHO "CREATE USER '$USER_LOGIN'@'localhost' IDENTIFIED BY '$MYSQL_USER_PASSWORD';" > $TMP_DIR/init.sql
$CMD_ECHO "CREATE DATABASE $MYSQL_DB_NAME;" >> $TMP_DIR/init.sql
$CMD_ECHO "GRANT ALL PRIVILEGES ON $MYSQL_DB_NAME.* TO '$USER_LOGIN'@'localhost';" >> $TMP_DIR/init.sql
$CMD_ECHO "commit;" >> $TMP_DIR/init.sql
$CMD_MYSQL < $TMP_DIR/init.sql
$CMD_MYSQL $MYSQL_DB_NAME < $PRJ_DIR/int_user_login.sql
$CMD_RM -f $TMP_DIR/init.sql

$CMD_MKDIR -m 700 $TMP_DIR

$CMD_ECHO "done."
$CMD_ECHO ""
$CMD_ECHO "Install nxlog on AD Server"
$CMD_ECHO "Change ip 99.99.99.99 on nxlog.conf to syslog's IP address"
$CMD_ECHO "Enable and start nxlog service"
$CMD_ECHO "Add to local crontab \"* * * * * /opt/int_user_login/bin/parse_int_user_login.sh ; cd /opt/int_user_login/php/ ; /usr/bin/php expire.php\""
