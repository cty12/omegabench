#!/usr/bin/bash

#
# The below script is a fork of the benchmarking script used in the Crane Project (https://github.com/columbia/crane).
# It is polished and improved and becomes part of our Omegabench Project (https://github.com/cty12/omegabench).
# Author: Tianyu Chen
# Date: May 12, 2016
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

# change $OMEGA_HOME
if [ "$OMEGA_HOME" == "" ]; then
    echo "${BOLD}${YELLOW}\$OMEGA_HOME${RESET}${BOLD} is not defined. Define it in your ${BLUE}.bashrc or .zshrc. ${RESET}"
    echo "${RED}${BOLD}TERMINATED${RESET}"
    exit 1
fi

# source config file
source $OMEGA_HOME/mongoose/config

# change working dir
cd "$APP_DIR"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# cleanup previous builds
# clear unpacked code base
rm -rf "mongoose-$MG_VER/"
# clear mongoose binary file
rm -f "mongoose" "mg.conf"

# download mongoose code base
if [ ! -f $MG_VER.tar.gz ]; then
    echo "${BOLD}Downloading mongoose source tarball... ${RESET}"
    wget "https://github.com/cesanta/mongoose/archive/$MG_VER.tar.gz"
fi

# untar
echo "${BOLD}Untarring the Mongoose server source file... ${RESET}"
tar zxf "$MG_VER.tar.gz"

# change working dir
cd "$APP_DIR/mongoose-$MG_VER"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# build mongoose
make linux
# copy binary to APP_DIR
cp mongoose $APP_DIR

# generate config file
# change working dir
cd "$APP_DIR"
MG_CONF="mg.conf"
touch $MG_CONF
echo "cgi_interpreter $OMEGA_HOME/apache-httpd/install-php/bin/php-cgi" >> $MG_CONF
echo "listening_ports 7000" >> $MG_CONF
echo "num_threads 8" >> $MG_CONF
echo "document_root $APP_DIR/www" >> $MG_CONF
