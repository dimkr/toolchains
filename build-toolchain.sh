#!/bin/sh -xe

cp -f config-$TRIPLET .config
./crosstool-ng/out/bin/ct-ng build
mkdir -p out
tar -c /opt/x-tools/$TRIPLET | xz -9 > out/$TRIPLET.tar.xz
