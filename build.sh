#!/bin/sh -xe 

cd crosstool-ng
./bootstrap
./configure --enable-local
make -j`nproc`

for i in ../config-*
do
    cp -f $i .config
    ./ct-ng build
done
