#!/bin/sh -xe

cp -f config-$TRIPLET .config
ct-ng build

grep -e ^CT_TARGET_CFLAGS= -e ^CT_TARGET_LDFLAGS= .config > /tmp/flags
. /tmp/flags
/bin/echo -e "#include <stdio.h>\n#include <stdlib.h>\n#include <math.h>\n#include <time.h>\nint main() {puts(\"hello\"); free(malloc(1)); return (int)floor((double)time(NULL)/3);}" | /opt/x-tools/$TRIPLET/bin/$TRIPLET-gcc $CT_TARGET_CFLAGS -x c -o /tmp/test - $CT_TARGET_LDFLAGS -lm
file /tmp/test > /tmp/test-$TRIPLET
/opt/x-tools/$TRIPLET/bin/$TRIPLET-readelf -A /tmp/test >> /tmp/test-$TRIPLET
diff -u test-$TRIPLET /tmp/test-$TRIPLET

tar -c /opt/x-tools/$TRIPLET | xz -9 > $TRIPLET.tar.xz
