#!/usr/bin/bash

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

if [[ ! -f /etc/debian_version ]]; then
	printf 'unsupported operating system\n' >&2
	exit 1
fi

usrbin="$HOME/.local/bin"
mkdir -p "$usrbin"
ln -fs "$PWD/bin/u.bash" "$usrbin/u"

if [[ -x /usr/bin/git ]]; then
	gitcfg="$HOME/.config/git"
	mkdir -p "$gitcfg"

	touch "$gitcfg/config"
	git config --global alias.fp 'push -f'
	git config --global alias.fresh 'commit --amend --date=now'
	git config --global alias.lol 'log --oneline'
	git config --global alias.s 'status'
	git config --global alias.u 'pull --prune'
	git config --global commit.verbose true

	for s in bs new supplant zap
	do ln -fs "$PWD/bin/git/$s.bash" "$usrbin/git-$s"
	done

	f="$HOME/.zshrc_local"
	touch "$f"
	if ! grep -q 'alias g=git' "$f"; then
		cat <<- EOF >> "$f"

		alias g=git
		EOF
	fi
fi

sudo apt-get update
sudo apt-get install -y zsh
ln -fs "$PWD/zsh/rc.zsh" ~/.zshrc

printf "\nPlease run 'history -c' before logout.\n"
