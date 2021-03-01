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

family=`echo $TRIPLET | cut -f 1 -d -`
endian=little
case $family in
	armeb)
		family=arm
		endian=big
		;;

	i?86)
		family=x86
		;;

	mips)
		endian=big
		;;

	mipsel)
		family=mips
		;;
esac

grep -e ^CT_TARGET_CFLAGS= -e ^CT_TARGET_LDFLAGS= .config > /tmp/flags
. /tmp/flags

mkdir -p /usr/local/share/meson/cross
cat << EOF > /usr/local/share/meson/cross/$TRIPLET
[host_machine]
system = 'linux'
cpu_family = '$family'
cpu = '`echo $CT_TARGET_CFLAGS | cut -f 2 -d = | cut -f 1 -d ' '`'
endian = '$endian'

[binaries]
c = ['ccache', '/opt/x-tools/$TRIPLET/bin/$TRIPLET-gcc']
as = '/opt/x-tools/$TRIPLET/bin/$TRIPLET-as'
ar = '/opt/x-tools/$TRIPLET/bin/$TRIPLET-ar'
strip = '/opt/x-tools/$TRIPLET/bin/$TRIPLET-strip'
cmake = 'cmake'
exe_wrapper = 'qemu-`echo $TRIPLET | cut -f 1 -d -`-static'

[properties]
c_args = ['`echo $CT_TARGET_CFLAGS | sed s/\ /"\', \'"/g`']
c_link_args = ['`echo $CT_TARGET_LDFLAGS | sed s/\ /"\', \'"/g`']
EOF
chmod 644 /usr/local/share/meson/cross/$TRIPLET

[ -d loksh ] || git clone https://github.com/dimkr/loksh
cd loksh
meson --cross-file=$TRIPLET --buildtype=release build-$TRIPLET
ninja -C build-$TRIPLET
cd ..

cat << EOF > /opt/x-tools/$TRIPLET/activate
export PATH=\$PATH:/opt/x-tools/$TRIPLET/bin
export CFLAGS="$CT_TARGET_CFLAGS \$CFLAGS"
export CXXFLAGS="$CT_TARGET_CFLAGS \$CXXFLAGS"
export LDFLAGS="$CT_TARGET_LDFLAGS \$LDFLAGS"
EOF
chmod 755 /opt/x-tools/$TRIPLET/activate

. /opt/x-tools/$TRIPLET/activate
/bin/echo -e "#include <stdio.h>\n#include <stdlib.h>\n#include <math.h>\n#include <time.h>\nint main() {puts(\"hello\"); free(malloc(1)); return (int)floor((double)time(NULL)/3);}" | $TRIPLET-gcc $CFLAGS -x c -o hello-$TRIPLET - $LDFLAGS -lm
/bin/echo -e "#include <iostream>\n#include <stdlib.h>\n#include <math.h>\n#include <time.h>\nint main() {std::cout << \"hello\"; free(malloc(1)); return (int)floor((double)time(NULL)/3);}" | $TRIPLET-g++ $CFLAGS -x c++ -o hello-cpp-$TRIPLET - $LDFLAGS -lm

for i in hello-$TRIPLET hello-cpp-$TRIPLET loksh/build-$TRIPLET/ksh
do
	$TRIPLET-strip -s -R.note -R.comment $i
	file $i | sed s/.*:\ // > /tmp/test-${i##*/}-$TRIPLET
	/opt/x-tools/$TRIPLET/bin/$TRIPLET-readelf -A $i | grep -v '00[1-9]' | cat >> /tmp/test-${i##*/}-$TRIPLET
	diff -u test-$TRIPLET /tmp/test-${i##*/}-$TRIPLET
done

tar -c /opt/x-tools/$TRIPLET /usr/local/share/meson/cross/$TRIPLET | gzip -9 > $TRIPLET.tar.gz
