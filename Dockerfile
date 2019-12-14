FROM debian:buster-slim

RUN apt-get update && apt-get install -y gcc g++ binutils bison flex texinfo xz-utils unzip help2man file gawk libtool-bin make patch libncurses5-dev autoconf automake gettext bzip2
