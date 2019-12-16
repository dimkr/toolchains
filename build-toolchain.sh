#!/bin/sh -xe

cp -f config-$TRIPLET .config
./crosstool-ng/out/bin/ct-ng build

grep -e ^CT_TARGET_CFLAGS= -e ^CT_TARGET_LDFLAGS= .config > /tmp/flags
. /tmp/flags
/bin/echo -e "#include <stdlib.h>\nint main() {free(malloc(0)); return 1;}" | /opt/x-tools/$TRIPLET/bin/$TRIPLET-gcc $CT_TARGET_CFLAGS $CT_TARGET_LDFLAGS -x c -o /tmp/test -
file /tmp/test > /tmp/test-$TRIPLET
/opt/x-tools/$TRIPLET/bin/$TRIPLET-readelf -A /tmp/test >> /tmp/test-$TRIPLET
diff -u test-$TRIPLET /tmp/test-$TRIPLET

tar -c /opt/x-tools/$TRIPLET | xz -9 > $TRIPLET.tar.xz
