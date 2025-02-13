#!/bin/sh

# Copyright (c) 2025 gh-nate
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

go telemetry off

f="$HOME/.zshrc_local"
touch "$f"
if ! grep -q GOPROXY "$f"; then
	cat << EOF >> "$f"

gomain() {
	printf 'package main\nfunc main() {}\n' > main.go
}

export GOBIN="\$HOME/.local/bin"
export GOPROXY='direct'
EOF
fi

if [ "$1" = "--offline" ]; then
	printf 'done\n'
	exit
fi

if [ ! "$GOPATH" ]; then
	printf 'please set GOPATH\n' >&2
	exit 1
fi

mkdir -p "$GOPATH"
cd "$GOPATH"

export GOPROXY='direct'

if [ ! "$GOBIN" ]; then
	printf 'please set GOBIN\n' >&2
	exit 1
fi

go install golang.org/x/pkgsite/cmd/pkgsite@latest
go install golang.org/x/website/tour@latest
mv "$GOBIN/tour" "$GOBIN/gotour"

curl -o spec.html https://go.dev/ref/spec

git clone https://github.com/mmcgrana/gobyexample
cd gobyexample
tools/build

if ! grep -q godoc "$f"; then
	cat << EOF >> "$f" 

if [[ -d "\$GOPATH/gobyexample" ]]; then
	alias gobyexample="cd \$GOPATH/gobyexample && tools/serve"
fi
if [[ -d /usr/lib/go/src ]]; then
	alias godoc='pkgsite /usr/lib/go/src'
fi
EOF
fi

printf 'done\n'
