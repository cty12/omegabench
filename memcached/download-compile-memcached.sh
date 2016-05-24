#!/usr/bin/bash

#
# The below script is a fork of the benchmarking script used in the Crane Project (https://github.com/columbia/crane).
# It is polished and improved and becomes part of our Omegabench Project (https://github.com/cty12/omegabench).
# Requires libevent-devel as dependency.
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

# cleanup previous builds
rm -rf memcached-$MEMCACHED_VER/
rm -rf install-memcached/

# download memcached code base
# for debug
echo "${BOLD}Memcached version${RESET} = $MEMCACHED_VER"

# download source code tarball
if [ ! -f memcached-$MEMCACHED_VER.tar.gz ]; then
    wget "http://www.memcached.org/files/memcached-$MEMCACHED_VER.tar.gz"
    RET=$?
    rm -f memcached-$MEMCACHED_VER.tar.gz.sha1
    wget "http://www.memcached.org/files/memcached-$MEMCACHED_VER.tar.gz.sha1"
    # check whether the download is successfully
    if [[ $RET -eq 0 && $? -eq 0 ]]; then
        echo "${GREEN}Download completed! ${RESET}"
        if [ "`sha1sum ./memcached-$MEMCACHED_VER.tar.gz`" == "`cat ./memcached-$MEMCACHED_VER.tar.gz.sha1`" ]; then
            echo "${GREEN}${BOLD}SHA1-sum checked! ${RESET}"
        else
            echo "${RED}${BOLD}SHA1-sum check failed! ${RESET}"
            exit 1
        fi
    else
        echo "${RED}${BOLD}Download failed with return code $RET! ${RESET}"
        exit 1
    fi
fi

# untar the source code
echo "${BOLD}Untarring the source code... ${RESET}"
tar -xf memcached-$MEMCACHED_VER.tar.gz
if [ $? -eq 0 ]; then
    echo "${GREEN}${BOLD}Untarred successfully! ${RESET}"
else
    echo "${RED}${BOLD}Untarred failed! ${RESET}"
    exit 2
fi

# change working dir
cd "$APP_DIR/memcached-$MEMCACHED_VER"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"
# configure & build
./configure --prefix=$APP_DIR/install-memcached
make && make install
# binary installed to install-memcached/

# whether the installation is successful
if [ $? -eq 0 ]; then
    echo "${BOLD}Memcached installation ${GREEN}DONE!!${RESET} Check the install-memcached/ directory. "
else
    echo "${BOLD}${RED}There might be some problems. ${RESET}"
    exit 3
fi

# change working dir
cd "$APP_DIR"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# cleanup previous libmemcached builds
rm -rf libmemcached-$LIBMEMCACHED_VER.tar.gz/
rm -rf install-libmemcached/

# for debug
echo "${BOLD}Libmemcached version${RESET} = $LIBMEMCACHED_VER"
echo "${BOLD}Libmemcached family${RESET} = ${LIBMEMCACHED_VER%.*}"

# download the source code tarball
if [ ! -f libmemcached-$LIBMEMCACHED_VER.tar.gz ]; then
    echo "${BOLD}Downloading libmemcached source tarball... ${RESET}"
    # download the file
    wget "https://launchpad.net/libmemcached/${LIBMEMCACHED_VER%.*}/$LIBMEMCACHED_VER/+download/libmemcached-$LIBMEMCACHED_VER.tar.gz"
    RET=$?
    # download the checksum
    rm -f libmemcached-$LIBMEMCACHED_VER.tar.gz.md5
    wget -O libmemcached-$LIBMEMCACHED_VER.tar.gz.md5 "https://launchpad.net/libmemcached/${LIBMEMCACHED_VER%.*}/$LIBMEMCACHED_VER/+download/libmemcached-$LIBMEMCACHED_VER.tar.gz/+md5"
    # check whether the download is successfully
    if [[ $RET -eq 0 && $? -eq 0 ]]; then
        echo "${GREEN}Download completed! ${RESET}"
        SUM=`md5sum libmemcached-$LIBMEMCACHED_VER.tar.gz | awk '{print $1;}'`
        SUM_REFER=`cat libmemcached-$LIBMEMCACHED_VER.tar.gz.md5 | head -n1 | awk '{print $1;}'`
        if [ "$SUM" == "$SUM_REFER" ]; then
            echo "${GREEN}${BOLD}MD5-sum checked! ${RESET}"
        else
            echo "${RED}${BOLD}MD5-sum check failed! ${RESET}"
            exit 1
        fi
    else
        echo "${RED}${BOLD}Download failed with return code $RET! ${RESET}"
        exit 1
    fi
fi

# untar the source code
echo "${BOLD}Untarring the libmemcached source code... ${RESET}"
tar -xf libmemcached-$LIBMEMCACHED_VER.tar.gz
if [ $? -eq 0 ]; then
    echo "${GREEN}${BOLD}Untarred successfully! ${RESET}"
else
    echo "${RED}${BOLD}Untarred failed! ${RESET}"
    exit 2
fi

# change working dir
cd "$APP_DIR/libmemcached-$LIBMEMCACHED_VER"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"
# configure & build
./configure --prefix=$APP_DIR/install-libmemcached
make && make install
# binary installed to install-libmemcached/

# whether the installation is successful
if [ $? -eq 0 ]; then
    echo "${BOLD}Libmemcached installation ${GREEN}DONE!!${RESET} Check the install-libmemcached/ directory. "
else
    echo "${BOLD}${RED}There might be some problems. ${RESET}"
    exit 3
fi

# you're all set!
