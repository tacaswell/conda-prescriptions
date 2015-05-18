#!/bin/bash

export EPICS_BASE=$PREFIX/epics
export EPICS_HOST_ARCH=linux-x86_64

# apply debian patches

while read f;do
    patch -p 1 < debian/patches/$f;
done < debian/patches/series

# set epics base
sed -i 's|EPICS_BASE = /usr/lib/epics|EPICS_BASE = '$EPICS_BASE'|g' debian/rules2

# don't try to compile for VME crates
sed -i 's|CROSS_COMPILER_TARGET_ARCHS += RTEMS-mvme3100||g' debian/rules2

# nuke DARCS in seq
sed -i 's|SEQ_TAG_TIME := $(shell darcs changes --all --xml-output |#|' seq/Makefile
sed -i 's_	--matches _#_' seq/Makefile



make -f debian/rules2 binfo

# run the debian build
make -f debian/rules2 all

# we need to do this _after_ building it once so that
# setting the install path does not break everything
sed -i  's|#INSTALL_LOCATION=|INSTALL_LOCATION='$SRC_DIR'/tmp_install|g' debian/rules2
mkdir tmp_install

# run the debian build
make -f debian/rules2 install

INTERESTING_DIRS="bin db dbd include lib templates"
for d in $INTERESTING_DIRS; do
    cp -r tmp_install/$d/* $PREFIX/epics/$d
done

echo '## link bin'
cd $PREFIX/bin
for fn in $PREFIX/epics/bin/$EPICS_HOST_ARCH/* ; do
    bn=`basename $fn`
    if [ ! -e $PREFIX/bin/$bn ]
       then
	   ln -s ../epics/bin/$EPICS_HOST_ARCH/$bn .
    fi
done

cd $PREFIX/lib
echo '## link lib'
for fn in $PREFIX/epics/lib/$EPICS_HOST_ARCH/*.so.* ; do
    bn=`basename $fn`
    if [ ! -e $PREFIX/lib/$bn ]
       then
	   ln -s ../epics/lib/$EPICS_HOST_ARCH/$bn .
    fi
done
