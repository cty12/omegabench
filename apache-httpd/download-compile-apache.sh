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
BOLD=`tput bold`
RESET=`tput sgr 0`

# versions
HTTPD_VER="2.4.20"
APR_VER="1.5.2"
APR_UTIL_VER="1.5.4"
PHP_VER="7.0.5"
# app root dir
APP_DIR="$OMEGA_HOME/apache-httpd/"

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
    echo "${BOLD}PHP compilation ${GREEN}DONE!! ${RESET} Check the install-php dir. "
fi
