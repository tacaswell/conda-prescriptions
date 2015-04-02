#!/bin/bash

export EPICS_BASE=$PREFIX/lib/epics
export EPICS_HOST_ARCH=linux-x86_64

cd configure
# deal with absurd build system which ships with hard coded paths from APS
sed -i 's|/corvette/usr/local/epics/base-3.14.12.4|'$EPICS_BASE'|' RELEASE
# turn of support I don't care about yet
sed -i 's|^IPAC|#IPAC|' RELEASE
sed -i 's|^SNCSEQ|#SCSEQ|' RELEASE

cd ../
PTH="bin db dbd include lib"
for pth in $PTH ; do
    echo $pth
done

make
