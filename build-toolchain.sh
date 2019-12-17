#!/bin/sh -xe

cp -f config-$TRIPLET .config
ct-ng build

grep -e ^CT_TARGET_CFLAGS= -e ^CT_TARGET_LDFLAGS= .config > /tmp/flags
. /tmp/flags
/bin/echo -e "#include <stdio.h>\n#include <stdlib.h>\n#include <math.h>\n#include <time.h>\nint main() {puts(\"hello\"); free(malloc(1)); return (int)floor((double)time(NULL)/3);}" | /opt/x-tools/$TRIPLET/bin/$TRIPLET-gcc $CT_TARGET_CFLAGS -x c -o hello-$TRIPLET - $CT_TARGET_LDFLAGS -lm
file hello-$TRIPLET > /tmp/test-$TRIPLET
/opt/x-tools/$TRIPLET/bin/$TRIPLET-readelf -A hello-$TRIPLET >> /tmp/test-$TRIPLET
diff -u test-$TRIPLET /tmp/test-$TRIPLET

tar -c hello-$TRIPLET /opt/x-tools/$TRIPLET | gzip -9 > $TRIPLET.tar.gz
