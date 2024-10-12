#!/bin/sh

# Copyright (c) 2024 gh-nate
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

set -e

ARCHIVE="v$1.tar.gz"
CODE="cpython-$1"

if ! test -f "$ARCHIVE"; then
	curl -LO "https://github.com/python/cpython/archive/refs/tags/$ARCHIVE"
fi

if ! test -d "$CODE"; then
	tar xzf "$ARCHIVE"
fi

# https://devguide.python.org/getting-started/setup-building/#build-dependencies

sudo apt-get build-dep python3

sudo apt-get install build-essential gdb lcov pkg-config \
	libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
	libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
	lzma lzma-dev tk-dev uuid-dev zlib1g-dev libmpdec-dev

# https://github.com/python/cpython/blob/3.13/README.rst#profile-guided-optimization

mkdir -p "$HOME/.local"

cd "$CODE"
./configure --enable-optimizations --with-lto --prefix="$HOME/.local"
make -j
make install

printf 'done\n'
