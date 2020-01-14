#!/bin/sh -e

(
	while true
	do
		sleep 60
		echo
	done
) &

set -x

cp -f config-$TRIPLET .config
ct-ng build

grep -e ^CT_TARGET_CFLAGS= -e ^CT_TARGET_LDFLAGS= .config > /tmp/flags
. /tmp/flags
cat << EOF > /opt/x-tools/$TRIPLET/activate
#!/bin/sh

export PATH=\$PATH:/opt/x-tools/$TRIPLET/bin
export CFLAGS="$CT_TARGET_CFLAGS \$CFLAGS"
export LDFLAGS="$CT_TARGET_LDFLAGS \$LDFLAGS"
EOF
chmod 755 /opt/x-tools/$TRIPLET/activate

. /opt/x-tools/$TRIPLET/activate
/bin/echo -e "#include <stdio.h>\n#include <stdlib.h>\n#include <math.h>\n#include <time.h>\nint main() {puts(\"hello\"); free(malloc(1)); return (int)floor((double)time(NULL)/3);}" | $TRIPLET-gcc $CFLAGS -x c -o hello-$TRIPLET - $LDFLAGS -lm
file hello-$TRIPLET > /tmp/test-$TRIPLET
/opt/x-tools/$TRIPLET/bin/$TRIPLET-readelf -A hello-$TRIPLET >> /tmp/test-$TRIPLET
diff -u test-$TRIPLET /tmp/test-$TRIPLET

tar -c hello-$TRIPLET /opt/x-tools/$TRIPLET | gzip -9 > $TRIPLET.tar.gz
