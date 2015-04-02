#!/bin/bash

export EPICS_BASE=$PREFIX/lib/epics
export EPICS_HOST_ARCH=linux-x86_64
PTH="as  bin  configure  db  dbd  extensions  include  iocBoot  lib  op  startup  templates"
for pth in $PTH; do
    install -d $EPICS_BASE/$pth
done

find ./ -name RELEASE | xargs sed -i 's|/APSshare/epics/base-3.14.12.3|/'$EPICS_BASE'|g'
find ./ -name RELEASE | xargs sed -i 's|/APSshare/epics/synApps_5_7/support|'$SRC_DIR'/support|g'
find ./  -wholename '*/configure/CONFIG*' -type f | xargs sed -i 's|INSTALL_LOCATION[ =]*$(TOP)|INSTALL_LOCATION = '$EPICS_BASE'|g'
find ./  -wholename '*/configure/CONFIG*' -type f | xargs sed -i 's|#INSTALL_LOCATION[ =]*<.*>|INSTALL_LOCATION = '$EPICS_BASE'|g'
#find ./  -wholename '*/configure/RELEASE' -type f | xargs sed -i 's|#INSTALL_LOCATION[ =]*<.*>|INSTALL_LOCATION = '$EPICS_BASE'|g'
#find ./  -wholename '*/RELEASE_SITE' -type f | xargs sed -i 's|EPICS_SITE_TOP=.*|EPICS_SITE_TOP = '$EPICS_BASE'|g'
#find ./  -wholename '*/configure/*' -type f | xargs sed -i 's|INSTALL_LOCATION=<.*>|INSTALL_LOCATION = '$EPICS_BASE'|g'
#find ./  -wholename '*/configure/*' -type f | xargs sed -i 's|INSTALL_LOCATION = <.*>|INSTALL_LOCATION = '$EPICS_BASE'|g'


cd support
SYNAPPS=$(find ./ -maxdepth 1 -type d | sed -rn 's|./([[:alpha:][:digit:]]*-[0-9][-[:digit:]]*)|\1|p')
for pth in $SYNAPPS; do
    touch $pth/RELEASE_SITE
done

make -j$(getconf _NPROCESSORS_ONLN)
