#!/usr/bin/bash

#
# The script starts the redis server on localhost.
# The configuration is stored in install-redis/redis.conf.
#
# Author: Tianyu Chen
# Date: May 25, 2016
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

# check $OMEGA_HOME
if [ "$OMEGA_HOME" == "" ]; then
    echo "${BOLD}${YELLOW}\$OMEGA_HOME${RESET}${BOLD} is not defined. Define it in your ${BLUE}.bashrc or .zshrc. ${RESET}"
    echo "${RED}${BOLD}TERMINATED${RESET}"
    exit 1
fi

# source config file
source $OMEGA_HOME/redis/config

# change working dir
cd $APP_DIR/install-redis/bin
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# kill previous running process
echo "${BOLD}Attempting to kill redis... ${RESET}"
killall redis-server
sleep 1

# bring up the server
echo "${YELLOW}${BOLD}(Re)starting redis server... ${RESET}"
./redis-server $APP_DIR/install-redis/redis.conf --protected-mode no

# sleep for a while...
sleep 0.5
# check whether redis server started successfully
PID=`pgrep redis-server`
if [ "$PID" == "" ]; then
    echo "${RED}${BOLD}Redis failed to start!! ${RESET}"
    exit 1
else
    echo "${GREEN}${BOLD}Redis started with PID $PID. ${RESET}"
fi

# check the port that redis is running on
echo "${CYAN}${BOLD}Checking the port redis server is running on. ${RESET}"
netstat -tlnp | grep `cat $APP_DIR/install-redis/redis.pid`
