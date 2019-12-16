#!/bin/sh -xe

cp -f config-$TRIPLET .config
./crosstool-ng/out/bin/ct-ng build
tar -c /opt/x-tools/$TRIPLET | xz -9 > $TRIPLET.tar.xz
