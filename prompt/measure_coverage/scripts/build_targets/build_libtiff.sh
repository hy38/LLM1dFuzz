#!/bin/bash

URL="https://gitlab.com/libtiff/libtiff/-/archive/v4.0.7/libtiff-v4.0.7.zip"

DIRNAME="libtiff-4.0.7"
ARCHIVE=$DIRNAME".zip"
LIBRARY="libtiff"
VERSION="4.0.7"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1
rm $ARCHIVE

# Stick to directory name conventions
mv $LIBRARY-v$VERSION $DIRNAME
cd $DIRNAME
./autogen.sh || exit 1

# Without ASAN
export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

./configure --disable-shared || exit 1
make -j || exit 1