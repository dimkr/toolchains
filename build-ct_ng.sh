#!/bin/sh -xe

[ ! -f out/bin/ct-ng ] || exit 0

cd crosstool-ng
./bootstrap
./configure --prefix=`pwd`/out
make -j`nproc` install
