#!/bin/bash

export EPICS_BASE=$PREFIX/lib/epics
export EPICS_HOST_ARCH=linux-x86_64

NPROC=$(getconf _NPROCESSORS_ONLN)

# apply debian patches

for f in debian/patches/*patch;do
    patch -p 1 < $f;
done ;

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
# set install path
sed -i  's|#INSTALL_LOCATION=|INSTALL_LOCATION='$PREFIX'/epics|g' debian/rules2

make -f debian/rules2 binfo

# run the debian build
make -f debian/rules2 install


echo '## link bin'
cd $PREFIX/bin
for fn in $PREFIX/epics/bin/$EPICS_HOST_ARCH/* ; do
    bn=`basename $fn`
    echo $fn, $bn
    if [ ! -e $PREFIX/bin/$bn ]
       then
	   ln -s ../epics/bin/$EPICS_HOST_ARCH/$bn .
	   echo 'linking ' $fn $bn
    fi
done

cd $PREFIX/lib
echo '## link lib'
for fn in $PREFIX/epics/lib/$EPICS_HOST_ARCH/*.so* ; do
    bn=`basename $fn`
    echo $fn, $bn
    if [ ! -e $EPICS_BASE/$bn ]
       then
	   ln -s ../epics/lib/$EPICS_HOST_ARCH/$bn .
	   echo 'linking ' $fn $bn
    fi
done
