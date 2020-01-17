#!/bin/sh -e

# Copyright (c) 2019, 2020 Dima Krasner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
export PATH=\$PATH:/opt/x-tools/$TRIPLET/bin
export CFLAGS="$CT_TARGET_CFLAGS \$CFLAGS"
export LDFLAGS="$CT_TARGET_LDFLAGS \$LDFLAGS"
EOF
chmod 755 /opt/x-tools/$TRIPLET/activate

. /opt/x-tools/$TRIPLET/activate
/bin/echo -e "#include <stdio.h>\n#include <stdlib.h>\n#include <math.h>\n#include <time.h>\nint main() {puts(\"hello\"); free(malloc(1)); return (int)floor((double)time(NULL)/3);}" | $TRIPLET-gcc $CFLAGS -x c -o hello-$TRIPLET - $LDFLAGS -lm
file hello-$TRIPLET > /tmp/test-$TRIPLET
/opt/x-tools/$TRIPLET/bin/$TRIPLET-readelf -A hello-$TRIPLET | grep -v '00[1-9]' | cat >> /tmp/test-$TRIPLET
diff -u test-$TRIPLET /tmp/test-$TRIPLET

tar -c /opt/x-tools/$TRIPLET | gzip -9 > $TRIPLET.tar.gz
