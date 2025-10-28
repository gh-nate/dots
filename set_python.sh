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

f="$HOME/.zlogout_local"
touch "$f"
if ! grep -q python "$f"; then
	cat << EOF >> "$f"

rm -f ~/.python_history
EOF
fi

f="$HOME/.zshrc_local"
touch "$f"
if ! grep -q python "$f"; then
	cat << EOF >> "$f"

function / {
	if [[ -f /etc/arch-release ]] && [[ ! -x /usr/bin/uv ]]; then
		sudo pacman -Sy uv
	elif [[ -f /etc/debian_version ]] && [[ ! -x ~/.local/bin/uv ]]; then
		curl --proto '=https' --tlsv1.2 -fsLS https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
		uv generate-shell-completion zsh > ~/.uv.zsh
		uvx --generate-shell-completion zsh >> ~/.uv.zsh
	fi
	uv run python -q
}

if [[ -r ~/.uv.zsh ]]; then . ~/.uv.zsh; fi
EOF
fi

printf 'done\n'
