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

if [ "$1" = "--no-docs" ]; then
	printf 'done\n'
	exit
fi

if [ ! "$GOPATH" ]; then
	printf 'please set GOPATH\n' >&2
	exit 1
fi

mkdir -p "$GOPATH"
cd "$GOPATH"

curl -o spec.html https://go.dev/ref/spec

export GOPROXY='direct'

if [ ! "$GOBIN" ]; then
	printf 'please set GOBIN\n' >&2
	exit 1
fi

go install golang.org/x/pkgsite/cmd/pkgsite@latest

if [ -f /etc/arch-release ]; then
	pkgsite_path=/usr/lib/go/src
elif [ -f /etc/debian_version ]; then
	if [ -x /usr/bin/go ]; then
		for pkgsite_path in /usr/share/go-*/src; do true; done
	fi
	while [ ! -d "$pkgsite_path" ]; do
		printf 'PATHS for pkgsite (hint: ends with something like go/src): '
		read -r pkgsite_path
	done
fi

dir="$HOME/.config/systemd/user"
mkdir -p "$dir"

service=pkgsite.service
printf '[Service]\n' > "$dir/$service"

if [ -f /etc/debian_version ] && [ ! -x /usr/bin/go ]; then
	# shellcheck disable=SC2046
	printf 'Environment=PATH=%s\n' $(dirname $(command -v go)) >> "$dir/$service"
fi

cat << EOF >> "$dir/$service"
ExecStart=$GOBIN/pkgsite -http 127.0.0.1:8001 $pkgsite_path

[Install]
WantedBy=default.target
EOF

go install golang.org/x/website/tour@latest
mv "$GOBIN/tour" "$GOBIN/gotour"

service=gotour.service
cat << EOF > "$dir/$service"
[Service]
ExecStart=$GOBIN/gotour -http 127.0.0.1:8002 -openbrowser=0

[Install]
WantedBy=default.target
EOF

if [ ! -d "$GOPATH/gobyexample" ]; then
	git clone https://github.com/mmcgrana/gobyexample
fi
cd gobyexample
git pull -p
tools/build

service=gobyexample.service
printf '[Service]\n' > "$dir/$service"

if [ -f /etc/debian_version ] && [ ! -x /usr/bin/go ]; then
	# shellcheck disable=SC2046
	printf 'Environment=PATH=/usr/bin:%s\n' $(dirname $(command -v go)) >> "$dir/$service"
fi

cat << EOF >> "$dir/$service"
ExecStart=$GOPATH/gobyexample/tools/serve
WorkingDirectory=$GOPATH/gobyexample

[Install]
WantedBy=default.target
EOF

systemctl --user enable --now \
	gobyexample.service \
	gotour.service \
	pkgsite.service

printf 'done\n'
