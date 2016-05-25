#!/usr/bin/bash

#
# The below script is a fork of the benchmarking script used in the Crane Project (https://github.com/columbia/crane).
# It is polished and improved and becomes part of our Omegabench Project (https://github.com/cty12/omegabench).
#
# Author: Tianyu Chen
# Date: May 25, 2016
# Organization: Tsinghua University
#
# Copyright (c) 2014, Regents of Columbia University
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other
# materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
source $OMEGA_HOME/redis/config

# change working dir
cd "$APP_DIR"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# cleanup previous builds
rm -rf redis-$REDIS_VER/
rm -rf install-redis/

# download redis code base
# for debug
echo "${BOLD}Redis version${RESET} = $REDIS_VER"
if [ ! -f redis-$REDIS_VER.tar.gz ]; then
    echo "${BOLD}Downloading Redis $REDIS_VER code base... ${RESET}"
    wget "http://download.redis.io/releases/redis-$REDIS_VER.tar.gz"
    # check whether download is successful
    if [ $? -eq 0 ]; then
        echo "${GREEN}${BOLD}Download completed! ${RESET}"
    else
        echo "${RED}${BOLD}Download failed! ${RESET}"
        exit 2
    fi
else
    echo "${GREEN}${BOLD}File already exists. Skip. ${RESET}"
fi

# Untar the source code
echo "${BOLD}Untarring the source code... ${RESET}"
tar -xf redis-$REDIS_VER.tar.gz
if [ $? -eq 0 ]; then
    echo "${GREEN}${BOLD}Untarred successfully! ${RESET}"
else
    echo "${RED}${BOLD}Untarred failed! ${RESET}"
    exit 2
fi

# change working dir
cd "$APP_DIR/redis-$REDIS_VER"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"
# configure & build
make
make install PREFIX=$APP_DIR/install-redis

# whether installation is successfully
if [ $? -eq 0 ]; then
    echo "${BOLD}Redis installation ${GREEN}DONE!!${RESET} Check the install-redis/ directory. "
else
    echo "${RED}${BOLD}There might be some problems. ${RESET}"
    exit 3
fi

# you might run make test here. this is optional but it's a good idea.
# make test

# you're set and ready to go
