```
 _              _      _           _
| |_ ___   ___ | | ___| |__   __ _(_)_ __  ___
| __/ _ \ / _ \| |/ __| '_ \ / _` | | '_ \/ __|
| || (_) | (_) | | (__| | | | (_| | | | | \__ \
 \__\___/ \___/|_|\___|_| |_|\__,_|_|_| |_|___/

```

[![Build Status](https://github.com/dimkr/toolchains/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/dimkr/toolchains/actions)

## Overview

This repository is a CI/CD pipeline for a collection of cross-compilation C/C++ toolchains that produce static binaries, carefully optimized for maximum hardware compatibility and small size.

These toolchains are ideal for training, research, debugging, CI and development of cross-platform software.

## Supported Architectures

Please read [ARCHITECTURES.md](./ARCHITECTURES.md) for information on currently supported architectures by toolchains.

## Usage

Pre-built toolchains are available [here](https://github.com/dimkr/toolchains/releases).

To install a toolchain, extract it to /opt/x-tools, e.g.:

```
curl -L https://github.com/dimkr/toolchains/releases/latest/download/arm-any32-linux-musleabi.tar.gz | sudo tar -xzvf - -C /
```

Each toolchain is accompanied by a [venv](https://docs.python.org/3/library/venv.html#creating-virtual-environments)-style "activation" script that sets environment variables.

For example, to build static [strace](https://strace.io) binaries for ARM:

```
HOST=arm-any32-linux-musleabi
. /opt/x-tools/$HOST/activate
curl https://strace.io/files/5.4/strace-5.4.tar.xz | tar -xJvf-
cd strace-5.4
./configure --host=$HOST
make
```

Another way to use the toolchains is using the [Meson](https://mesonbuild.com) build system: each toolchain has a matching cross-file under /usr/local/share/meson/cross.

For example, to build [papaw](https://github.com/dimkr/papaw) for ARM:

```
HOST=arm-any32-linux-musleabi
git clone --recursive https://github.com/dimkr/papaw
cd papaw
meson --cross-file=$HOST build
ninja -C build
```

## Legal Information

This is free and unencumbered software released under the terms of the MIT license; see COPYING for the license text.

The ASCII art logo at the top was made using [FIGlet](http://www.figlet.org/).
