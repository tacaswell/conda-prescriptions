#!/bin/bash

export EPICS_BASE=$PREFIX/lib/epics
export EPICS_HOST_ARCH=linux-x86_64

# apply debian patches

for f in debian/patches/*patch;do
    patch -p 1 < $f;
done ;

# set epics base
sed -i 's|EPICS_BASE = /usr/lib/epics|EPICS_BASE = '$EPICS_BASE'|g' debian/rules2

# don't try to compile for VME crates
sed -i 's|CROSS_COMPILER_TARGET_ARCHS += RTEMS-mvme3100||g' debian/rules2
# don't try to compile stream, fails for reasons not yet understood
#sed -i 's|MODS += stream||' debian/rules2
#sed -i 's|stream_DEPS = asyn calc sscan||' debian/rules2

# nuke DARCS in seq
sed -i 's|SEQ_TAG_TIME := $(shell darcs changes --all --xml-output |#|' seq/Makefile
sed -i 's_	--matches _#_' seq/Makefile

make -f debian/rules2 binfo

# run the debian build
make -f debian/rules2 all

# set install path
sed -i  's|#INSTALL_LOCATION=|INSTALL_LOCATION='$PREFIX'/epics_base|g' debian/rules2

make -f debian/rules2 binfo

# run the debian build
make -f debian/rules2 install
