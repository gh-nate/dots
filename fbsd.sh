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

cat << EOF >> ~/.shrc

alias ll='ls -hAlp'

HISTFILE=
LESSHISTFILE='-'
export LESSHISTFILE

if [ -r ~/.shrc_local ]
then . ~/.shrc_local
fi
EOF

mkdir -p ~/bin
ln -fs /usr/libexec/flua ~/bin/lua

cat << EOF > ~/.nexrc
set autoindent
set number
EOF

if [ -r "$PWD/zsh/rc.zsh" ]
then ln -fs "$PWD/zsh/rc.zsh" ~/.zshrc
fi
if [ -x /usr/local/bin/zsh ]
then chsh -s /usr/local/bin/zsh
fi

if [ -r "$PWD/tmux.conf" ]
then ln -fs "$PWD/tmux.conf" ~/.tmux.conf
fi

echo 'done'
