FROM debian:buster-slim

RUN apt-get update && apt-get install -y gcc g++ binutils bison flex texinfo xz-utils unzip help2man file gawk libtool-bin make patch libncurses5-dev autoconf automake gettext bzip2 ccache
RUN /bin/echo -e "#!/bin/sh\nexec /usr/bin/ccache /usr/bin/gcc \"\$@\"" > /usr/local/bin/gcc && chmod 755 /usr/local/bin/gcc && ln -s gcc /usr/local/bin/cc && mkdir -p /root/.ccache && /bin/echo -e "max_size = 5.0G\nhash_dir = false" > /root/.ccache/ccache.conf
