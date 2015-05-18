#!/bin/bash
install -d $PREFIX/bin
install -d $PREFIX/lib
install -d $PREFIX/epics

export EPICS_BASE=$PREFIX/epics
export EPICS_HOST_ARCH=$(startup/EpicsHostArch)

NPROC=$(getconf _NPROCESSORS_ONLN)

# apply debian patches

while read f;do
    patch -p 1 < debian/patches/$f;
done < debian/patches/series

make -j$(getconf _NPROCESSORS_ONLN)
make install

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
for fn in $PREFIX/epics/lib/$EPICS_HOST_ARCH/*.so* ; do
    bn=`basename $fn`
    if [ ! -e $EPICS_BASE/$bn ]
       then
	   ln -s ../epics/lib/$EPICS_HOST_ARCH/$bn .
    fi
done


# deal with env export
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

ACTIVATE=$PREFIX/etc/conda/activate.d/epics_base.sh
DEACTIVATE=$PREFIX/etc/conda/deactivate.d/epics_base.sh
ETC=$PREFIX/etc

# set up
echo "export EPICS_BASE="$EPICS_BASE >> $ACTIVATE
echo "export EPICS_HOST_ARCH="$EPICS_HOST_ARCH >> $ACTIVATE

# tear down
echo "unset EPICS_BASE" >> $DEACTIVATE
echo "unset EPICS_HOST_ARCH" >> $DEACTIVATE

# clean up after self
unset ACTIVATE
unset DEACTIVATE
unset ETC
