#!/usr/bin/bash

#
# The script starts the memcached as service.
#
# Author: Tianyu Chen
# Date: May 24, 2016
# Organization: Tsinghua University
#

# text styles
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
BOLD=`tput bold`
RESET=`tput sgr 0`

# check $OMEGA_HOME
if [ "$OMEGA_HOME" == "" ]; then
    echo "${BOLD}${YELLOW}\$OMEGA_HOME${RESET}${BOLD} is not defined. Define it in your ${BLUE}.bashrc or .zshrc. ${RESET}"
    echo "${RED}${BOLD}TERMINATED${RESET}"
    exit 1
fi

# source config file
source $OMEGA_HOME/memcached/config

# change working dir
cd "$APP_DIR/install-memcached/bin"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# kill previous running process
echo "${BOLD}Attempting to kill memcached... ${RESET}"
killall memcached
sleep 1

# start memcached
echo "${YELLOW}${BOLD}(Re)starting memcached... ${RESET}"
./memcached -p $PORT -P $APP_DIR/install-memcached/memcached.pid &

# sleep for a while...
sleep 0.5
# check whether memcached is started successfully
PID=`pgrep memcached`
if [ "$PID" == "" ]; then
    echo "${RED}${BOLD}Memcached failed to start!! ${RESET}"
    exit 1
else
    echo "${GREEN}${BOLD}Memcached started with PID $PID. ${RESET}"
fi
