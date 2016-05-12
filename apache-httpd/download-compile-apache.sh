#!/usr/bin/bash

#
# The below script is a fork of the benchmarking script used in the Crane Project (https://github.com/columbia/crane).
# It is polished and improved and becomes part of our Omegabench Project.
# Author: Tianyu Chen
# Date: May 10, 2016
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

# versions
HTTPD_VER="2.4.20"
APR_VER="1.5.2"
APR_UTIL_VER="1.5.4"
PHP_VER="7.0.5"
# app root dir
APP_DIR="$OMEGA_HOME/apache-httpd/"

if [ "$OMEGA_HOME" == "" ]; then
    echo "${BOLD}${YELLOW}\$OMEGA_HOME${RESET}${BOLD} is not defined. Define it in your ${BLUE}.bashrc or .zshrc. ${RESET}"
    echo "${RED}${BOLD}TERMINATED${RESET}"
    exit 1
fi

# change working dir
cd $APP_DIR
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# cleanup previous builds
rm -rf "httpd-$HTTPD_VER/"
rm -rf "install/"
rm -rf "php-$PHP_VER/"
rm -rf "install-php/"

# download apache code base
echo "${BOLD}Downloading Apache-httpd source tarball... ${RESET}"
if [ ! -f httpd-$HTTPD_VER.tar.gz ]; then
    wget "https://archive.apache.org/dist/httpd/httpd-$HTTPD_VER.tar.gz"
fi
echo "${BOLD}Downloading Apache portable runtime source... ${RESET}"
if [ ! -f apr-$APR_VER.tar.gz ]; then
    wget "http://apache.fayea.com/apr/apr-$APR_VER.tar.gz"
fi
if [ ! -f apr-util-$APR_UTIL_VER.tar.gz ]; then
    wget "http://apache.fayea.com/apr/apr-util-$APR_UTIL_VER.tar.gz"
fi

# untar
echo "${BOLD}Untarring the Apache source file... ${RESET}"
tar zxf "httpd-$HTTPD_VER.tar.gz"
tar zxf "apr-$APR_VER.tar.gz" -C "$APP_DIR/httpd-$HTTPD_VER/srclib"
mv "$APP_DIR/httpd-$HTTPD_VER/srclib/apr-$APR_VER" "$APP_DIR/httpd-$HTTPD_VER/srclib/apr"
tar zxf "apr-util-$APR_UTIL_VER.tar.gz" -C "$APP_DIR/httpd-$HTTPD_VER/srclib"
mv "$APP_DIR/httpd-$HTTPD_VER/srclib/apr-util-$APR_UTIL_VER" "$APP_DIR/httpd-$HTTPD_VER/srclib/apr-util"
echo "${BOLD}Check the srclib contents: ${RESET}"
ls -l "$APP_DIR/httpd-$HTTPD_VER/srclib"

# change working dir
cd "$APP_DIR/httpd-$HTTPD_VER"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"
# configure & build
./configure \
        --with-mpm=worker \
        --prefix=$APP_DIR/install \
        --with-devrandom=/dev/urandom \
        --disable-proxy \
        --with-included-apr

make -j4
make install

if [ $? -eq 0 ]; then
    echo "${BOLD}Apache compilation ${GREEN}DONE!! ${RESET} Check the install/bin dir: "
    ls -l "$APP_DIR/install/bin"
fi

# download php code bash
# change working dir
cd $APP_DIR
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"
if [ ! -f php-$PHP_VER.tar.gz ]; then
    wget http://hk1.php.net/get/php-$PHP_VER.tar.gz/from/this/mirror -O php-$PHP_VER.tar.gz
fi

# untar
echo "${BOLD}Untarring the PHP source file... ${RESET}"
tar xzf "php-$PHP_VER.tar.gz"

# change working dir
cd $APP_DIR/php-$PHP_VER
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"
# configure & build
./configure \
        --prefix=$APP_DIR/install-php \
        --with-apxs2=$APP_DIR/install/bin/apxs \
        --disable-dom \
        --disable-simplexml

make -j4
make install

if [ $? -eq 0 ]; then
    echo "${BOLD}PHP compilation ${GREEN}DONE!! ${RESET} Check the install-php/ dir. "
fi

# edit apache-httpd config files
# change working dir
cd $APP_DIR/install/conf
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"
if [ ! -f httpd.conf.ob.bak ]; then
    # make backup
    echo "Backing up ${YELLOW}${BOLD}install/conf/httpd.conf${RESET} to ${BLUE}${BOLD}install/conf/httpd.conf.ob.bak${RESET}"
    cp httpd.conf httpd.conf.ob.bak
fi
# replace the default listening port of the httpd server
sed -i -e "s/Listen 80/Listen 7000/g" httpd.conf
echo "Listening port of Apache-httpd changed to: ${BLUE}${BOLD}`egrep "^Listen " httpd.conf`${RESET}"
# set handler for .php files
sed -i "/<IfModule mime_module>/a\ \ \ \ # Handle .php files\n\ \ \ \ AddType application/x-httpd-php .php\n" httpd.conf
# set server name
echo "# Configuration for Omegabench" >> httpd.conf
echo "ServerName localhost" >> httpd.conf
# set server limit
echo "ServerLimit 1" >> httpd.conf
# set threads-per-child
echo "ThreadsPerChild 8" >> httpd.conf
# end with blank line
echo "" >> httpd.conf
echo "${BOLD}Additional Apache-httpd configuration: ${RESET}"
tail -n 5 httpd.conf
# set up the test web page (in php)
cp $APP_DIR/test.php $APP_DIR/install/htdocs
echo "${BOLD}Files under directory install/htdocs: ${RESET}"
ls -l $APP_DIR/install/htdocs
