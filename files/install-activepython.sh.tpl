#!/bin/bash
VERSION=3.6.0.3600
RELEASES=http://downloads.activestate.com/ActivePython/releases
FNAME=`wget ${RELEASES}/${VERSION}/ -q -O - | grep "linux-x86_64" | grep "tar.gz"  | head -n 1  | sed -n 's/.*href="\([^"]*\).*$/\1/p'`
BINARIES=/opt/bin
INSTALL=/opt/python

# Download archive
wget ${RELEASES}/${VERSION}/${FNAME}

# make directory
mkdir -p ${BINARIES}

# Extract to target directory
tar -xzvf ${FNAME} -C ${BINARIES}

# Install
./`find .${BINARIES}/ActivePython-* -type d | head -n 1`/install.sh -I ${INSTALL}

# Symlink executables
ln -s ${INSTALL}/bin/easy_install /opt/bin/easy_install
ln -s ${INSTALL}/bin/virtualenv /opt/bin/virtualenv
ln -s ${INSTALL}/bin/python /opt/bin/python
ln -s ${INSTALL}/bin/pip /opt/bin/pip
