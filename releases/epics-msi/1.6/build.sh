#!/bin/bash

export EPICS_BASE=$PREFIX/lib/epics
export EPICS_HOST_ARCH=linux-x86_64

cd ../
wget http://www.aps.anl.gov/epics/download/extensions/extensionsTop_20120904.tar.gz
tar xzf extensionsTop_20120904.tar.gz
mv msi1-6 extensions/src/msi

cd extensions

sed -i 's|$(TOP)/../base|'$EPICS_BASE'|g' configure/RELEASE

make

install -d $PREFIX/bin
install bin/$EPICS_HOST_ARCH/* $PREFIX/bin
