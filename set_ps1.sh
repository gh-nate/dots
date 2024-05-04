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

local_zsh_config="$HOME/.zshrc_local"

if ! test -f "$local_zsh_config"; then
	touch "$local_zsh_config"
fi

if ! grep -q vcs_info "$local_zsh_config"; then
	cat <<- EOF >> "$local_zsh_config"

	autoload -Uz vcs_info

	zstyle ':vcs_info:*' enable git
	zstyle ':vcs_info:git:*' formats "%B(%b)%%b "

	precmd() { vcs_info }
	PS1='%B%~%b \${vcs_info_msg_0_}%# '

	setopt prompt_subst
	EOF
fi

printf 'done\n'
