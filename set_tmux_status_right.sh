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

a="$HOME/.tmux_local.conf"
b="$HOME/.local/bin"
c=tmux-git-branch
d="$b/$c"

if ! test -f "$a"; then
	touch "$a"
fi

if ! grep -q "$c" "$a"; then
	cat <<- EOF >> "$a"
	set -g status-left '[#S#(tmux-git-branch)] '
	set -g status-left-length 40
	set -g status-interval 1
	EOF
fi

if ! test -f "$d"; then
	mkdir -p "$b"
	tab="$(printf '\t')"
	cat <<- EOF >> "$d"
	set -e

	if git rev-parse 2> /dev/null; then
	${tab}printf ':%s' "\$(git branch --show-current)"
	fi
	EOF

	chmod +x "$d"
fi

printf 'done\n'
