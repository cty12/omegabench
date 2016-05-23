#!/usr/bin/bash

#
# The script is part of the Omegabench project.
# It does some preparation jobs and deploys the mysql server
# before running the sysbench benchmark.
#
# Author: Tianyu Chen
# Date: May 23, 2016
# Organization: Tsinghua University
#

# text styles
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
BOLD=`tput bold`
RESET=`tput sgr 0`

# for debug
echo "${CYAN}${BOLD}Preparing sysbench benchmark!! ${RESET}"

# source the config file
source $OMEGA_HOME/mysql/config
echo "${BOLD}Test table size${RESET} = $TABLE_SIZE"

# change working dir
cd $APP_DIR
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# kill previously running mysql server
echo "Attempting to kill mysqld... "
killall mysqld
sleep 1

# for debug; check whether there is still socket
# ls -l /tmp/mysql.sock

# restart mysql server
echo "${BLUE}${BOLD}(Re)starting mysql server... ${RESET}"
install-mysql/libexec/mysqld --defaults-file=./my.cnf &
# deamon started
sleep 1
# check whether mysqld is active
if [ "`pgrep mysqld`" == "" ]; then
    # mysql server is not running; quit
    echo "${RED}${BOLD}ERROR - mysql server is DEAD! ${RESET}"
    exit 1
else
    echo "${GREEN}${BOLD}Mysql server is running with pid `pgrep mysqld`${RESET}"
fi

# dealing with privileges so the database can be accessed from other hosts
install-mysql/bin/mysql -u root -e 'GRANT ALL PRIVILEGES ON *.* TO "root"@"%";'
install-mysql/bin/mysql -u root -e 'FLUSH PRIVILEGES;'

# drop previous test database
install-mysql/bin/mysql -u $USER -e "drop database $DATABASE;"
if [ $? -eq 0 ]; then
    echo "${GREEN}${BOLD}Database $DATABASE dropped successfully! ${RESET}"
else
    echo "${YELLOW}${BOLD}Database $DATABASE does not exist. Will not drop it. ${RESET}"
fi
# sleep for a while for robustness
sleep 1

# create new database
install-mysql/bin/mysql -u $USER -e "create database $DATABASE;"

# do sysbench preparation...
install-sysbench/bin/sysbench \
        --mysql-host=127.0.0.1 \
        --mysql-port=$PORT \
        --mysql-user=$USER \
        --test=$APP_DIR/sysbench-$SYSBENCH_VER/sysbench/tests/db/oltp.lua \
        --oltp-table-size=$TABLE_SIZE \
        --oltp-table-name=sbtest \
        --mysql-table-engine=InnoDB \
        --mysql-engine-trx=yes \
        --mysql-db=$DATABASE \
        prepare

# check whether the preparation is successful
if [ $? -eq 0 ]; then
    echo "${GREEN}${BOLD}Sysbench is ready to use! ${RESET}"
else
    echo "${RED}${BOLD}Sysbench-prepare failed with exit code $?. ${RESET}"
    exit 2
fi
