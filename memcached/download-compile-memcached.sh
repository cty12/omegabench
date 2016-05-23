#!/usr/bin/bash

#
# The below script is a fork of the benchmarking script used in the Crane Project (https://github.com/columbia/crane).
# It is polished and improved and becomes part of our Omegabench Project (https://github.com/cty12/omegabench).
#
# Author: Tianyu Chen
# Date: May 23, 2016
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
source $OMEGA_HOME/memcached/config

# change working dir
cd "$APP_DIR"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# TODO cleanup previous builds

# download memcached code base
# for debug
echo "${BOLD}Memcached version${RESET} = $MEMCACHED_VER"

# download source code tarball
if [ ! -f memcached-$MEMCACHED_VER.tar.gz ]; then
    wget "http://www.memcached.org/files/memcached-$MEMCACHED_VER.tar.gz"
    rm -f memcached-$MEMCACHED_VER.tar.gz.sha1
    wget "http://www.memcached.org/files/memcached-$MEMCACHED_VER.tar.gz.sha1"
    # check whether the download is successfully
    if [ $? -eq 0 ]; then
        echo "${GREEN}Download completed! ${RESET}"
        if [ "`sha1sum ./memcached-$MEMCACHED_VER.tar.gz`" == "`cat ./memcached-$MEMCACHED_VER.tar.gz.sha1`" ]; then
            echo "${GREEN}${BOLD}SHA1-sum checked! ${RESET}"
        else
            echo "${RED}${BOLD}SHA1-sum check failed! ${RESET}"
            exit 1
        fi
    else
        echo "${RED}${BOLD}Download failed with return code $?! ${RESET}"
        exit 1
    fi
fi
