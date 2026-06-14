#!/bin/sh

# Copyright (c) 2026 gh-nate
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

set -eu

if [ ! -f /etc/debian_version ]; then
	printf 'unsupported operating system\n' >&2
	exit 1
fi

usrbin="$HOME/.local/bin"
mkdir -p "$usrbin"
ln -fs "$PWD/bin/t.sh" "$usrbin/t"
ln -fs "$PWD/bin/u.sh" "$usrbin/u"

if [ -x /usr/bin/git ]; then sh git.sh; fi

sudo apt-get update
sudo apt-get install -y zsh
ln -fs "$PWD/zsh/rc.zsh" ~/.zshrc
chsh -s /usr/bin/zsh

tmx="$HOME/.config/tmux"
mkdir -p "$tmx"
ln -fs "$PWD/tmux.conf" "$tmx/tmux.conf"

printf "\nplease run 'history -c' before logging out.\n"
