#!/usr/bin/bash

#
# The script is part of the Omegabench project.
# It downloads and compiles the `tar` and `xz` program before testing the
# compression capability of target hosts.
# The script requires tar and xz as dependencies.
#
# Author: Tianyu Chen
# Date: May 18, 2016
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
source $OMEGA_HOME/xz/config

# for debug
echo "${BOLD}Xz version to use:${RESET} $XZ_VER. "
echo "${BOLD}Tar version to use:${RESET} $TAR_VER. "

# change working dir
cd "$APP_DIR"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"

# cleanup previous builds
# remove code bases
rm -rf tar-$TAR_VER/
rm -rf xz-$XZ_VER/
# remove binary directories
rm -rf install-xz/

# download tar code base
if [ ! -f tar-$TAR_VER.tar.xz ]; then
    echo "${BOLD}Downloading tar source tarball... ${RESET}"
    wget "http://ftp.gnu.org/gnu/tar/tar-$TAR_VER.tar.xz"
fi
# untar
echo "${BOLD}Untarring the tar code base... ${RESET}"
tar -xf tar-$TAR_VER.tar.xz

# download xz code base
if [ ! -f xz-$XZ_VER.tar.xz ]; then
    echo "${BOLD}Downloading xz source tarball... ${RESET}"
    wget "http://tukaani.org/xz/xz-$XZ_VER.tar.xz"
fi
# untar
echo "${BOLD}Untarring the xz code base... ${RESET}"
tar -xf xz-$XZ_VER.tar.xz

# change working dir
cd "$APP_DIR/xz-$XZ_VER"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"
# configure & build
./configure --prefix=$APP_DIR/install-xz
make -j4
make install

# change working dir
cd "$APP_DIR/tar-$TAR_VER"
echo "${BOLD}Working dir changed to ${GREEN}`pwd`${RESET}"
# configure & build
./configure --prefix=$APP_DIR/install-tar
make -j4
make install
