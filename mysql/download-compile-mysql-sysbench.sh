#/usr/bin/bash

#
# The below script is a fork of the benchmarking script used in the Crane Project (https://github.com/columbia/crane).
# It is polished and improved and becomes part of our Omegabench Project (https://github.com/cty12/omegabench).
# Requires unzip, libtool as dependency.
# Author: Tianyu Chen
# Date: May 20, 2016
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
source $OMEGA_HOME/mysql/config

# change working dir
cd "$APP_DIR"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# cleanup previous builds
# remove code bases
rm -rf mysql-$MYSQL_VER/
# remove binary directories
rm -rf install-mysql/
# remove previous mysql settings
rm -f my.cnf

# download mysql code base from mirror
# we use Shu-Te University mirror here
# for debug
echo "${BOLD}MySQL version${RESET} = $MYSQL_VER"
echo "${BOLD}MySQL family${RESET} = ${MYSQL_VER%.*}"

# download source code tarball
if [ ! -f mysql-$MYSQL_VER.tar.gz ]; then
    echo "${BOLD}Downloading mysql source tarball... ${RESET}"
    wget "ftp://ftp.stu.edu.tw/pub/Unix/Database/Mysql/Downloads/MySQL-${MYSQL_VER%.*}/mysql-$MYSQL_VER.tar.gz"
    # check whether the download is successful
    if [ $? -eq 0 ]; then
        echo "${GREEN}${BOLD}Download completed! ${RESET}"
    else
        echo "${RED}${BOLD}Download failed with return code $?! ${RESET}"
        exit 1
    fi
fi

# untar the source tarball
echo "${BOLD}Untarring the source tarball... ${RESET}"
tar -xf mysql-$MYSQL_VER.tar.gz
# change working dir
cd "$APP_DIR/mysql-$MYSQL_VER"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"
# configure & build
./configure --prefix=$APP_DIR/install-mysql
make && make install
# binary installed to install-mysql/

# whether the installation is successful
if [ $? -eq 0 ]; then
    echo "${BOLD}Mysql installation ${GREEN}DONE!!${RESET} Check the install-mysql/ directory. "
else
    echo "${BOLD}${RED}There might be some problems. ${RESET}"
fi

# change working dir
cd "$APP_DIR"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# cleanup previous sysbench installation
rm -rf sysbench-$SYSBENCH_VER/
rm -rf install-sysbench

# for debug
echo "${BOLD}SYSBENCH version${RESET} = $SYSBENCH_VER"

# download source code tarball
# use the GitHub mirror
if [ ! -f $SYSBENCH_VER.zip ]; then
    wget https://github.com/akopytov/sysbench/archive/$SYSBENCH_VER.zip
    # check whether the download is successful
    if [ $? -eq 0 ]; then
        echo "${GREEN}${BOLD}Download completed! ${RESET}"
    else
        echo "${RED}${BOLD}ownload failed with exit code $?! ${RESET}"
        exit 1
    fi
fi

# unzip the source code
echo "${BOLD}Unzipping the source... ${RESET}"
unzip -q $SYSBENCH_VER.zip
if [ $? -eq 0 ]; then
    echo "${GREEN}${BOLD}Unzipped successfully! ${RESET}"
else
    echo "${RED}${BOLD}Unzipping failed! ${RESET}"
    exit 2
fi

# change working directory
cd "$APP_DIR/sysbench-$SYSBENCH_VER"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# configure & build
./autogen.sh
./configure \
        --prefix=$APP_DIR/install-sysbench \
        --with-mysql-includes=$APP_DIR/install-mysql/include/mysql \
        --with-mysql-libs=$APP_DIR/install-mysql/lib/mysql
make && make install
# binary installed to install-mysql/

# whether the installation is successfully
if [ $? -eq 0 ]; then
    echo "${BOLD}SYSBENCH installation ${GREEN}DONE!!${RESET} Check the install-sysbench/ directory. "
else
    echo "${BOLD}${RED}There might be some problems. ${RESET}"
fi

# change working directory
cd "$APP_DIR"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# generate the mysql test configuration
sed -e "s/3306/$PORT/g" install-mysql/share/mysql/my-large.cnf > my.cnf
# initialize the database
./install-mysql/bin/mysql_install_db --defaults-file=./my.cnf

# now the mysql database is ready to run
# use sysbench to benchmark the performance of mysql
