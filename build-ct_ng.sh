#!/bin/sh -xe

[ ! -f crosstool-ng/out/bin/ct-ng ] || exit 0

cd crosstool-ng
./bootstrap
./configure --prefix=`pwd`/out
make -j`nproc` install
