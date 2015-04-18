#!/bin/bash

export EPICS_BASE=$PREFIX/lib/epics
export EPICS_HOST_ARCH=linux-x86_64

cd support
SYNAPPS=$(find ./ -maxdepth 1 -type d | sed -rn 's|./([[:alpha:][:digit:]]*-[0-9][-[:digit:]]*)|\1|p')

PTH="as configure  db  dbd  extensions  include  iocBoot  lib  op  startup  templates"
for pth in $PTH; do
    install -d $EPICS_BASE/$pth
    ln -s $EPICS_BASE/$pth $pth
    for dir in $SYNAPPS; do
        ln -s $EPICS_BASE/$pth $dir/$pth
    done
done

for dir in $SYNAPPS; do
    install -d $dir/$EPICS_HOST_ARCH
    ln -s $EPICS_BASE/$pth $dir/$EPICS_HOST_ARCH/$pth
done

find ./ -name RELEASE |
find ./ -name RELEASE | xargs sed -i 's|/APSshare/epics/synApps_5_7/support|'$SRC_DIR'/support|g'
find ./  -wholename '*/configure/CONFIG*' -type f | xargs sed -i 's|INSTALL_LOCATION[ =]*$(TOP)|INSTALL_LOCATION = '$EPICS_BASE'|g'
find ./  -wholename '*/configure/CONFIG*' -type f | xargs sed -i 's|#INSTALL_LOCATION[ =]*<.*>|INSTALL_LOCATION = '$EPICS_BASE'|g'
#find ./  -wholename '*/configure/RELEASE' -type f | xargs sed -i 's|#INSTALL_LOCATION[ =]*<.*>|INSTALL_LOCATION = '$EPICS_BASE'|g'
#find ./  -wholename '*/RELEASE_SITE' -type f | xargs sed -i 's|EPICS_SITE_TOP=.*|EPICS_SITE_TOP = '$EPICS_BASE'|g'
#find ./  -wholename '*/configure/*' -type f | xargs sed -i 's|INSTALL_LOCATION=<.*>|INSTALL_LOCATION = '$EPICS_BASE'|g'
#find ./  -wholename '*/configure/*' -type f | xargs sed -i 's|INSTALL_LOCATION = <.*>|INSTALL_LOCATION = '$EPICS_BASE'|g'


make #-j$(getconf _NPROCESSORS_ONLN)
