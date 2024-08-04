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

if [ -r /etc/os-release ]; then
	# shellcheck source=/dev/null
	. /etc/os-release
	if [ "$ID" = debian ] || [ "$ID_LIKE" = debian ]; then
		BIN=/usr/bin
		USRBIN="$HOME/.local/bin"
	elif [ "$ID" = freebsd ]; then
		BIN=/usr/local/bin
		USRBIN="$HOME/bin"
	else
		ID=
	fi
fi

if [ -z "$ID" ]; then
	printf 'unsupported operating system\n' >&2
	exit 1
fi

if [ -x "$BIN/git" ]; then
	GITCONFIG="$HOME/.config/git"
	mkdir -p "$GITCONFIG"

	touch "$GITCONFIG/config"
	git config --global alias.fresh 'commit --amend --date=now'
	git config --global alias.lol 'log --oneline'
	git config --global commit.verbose true

	cat <<- EOF > "$GITCONFIG/ignore"
	*.swp
	EOF

	mkdir -p "$USRBIN"

	set_exit_immediately() { printf 'set -e\n\n' > "$1"; }

	set_exit_immediately "$USRBIN/git-new"
	cat <<- EOF >> "$USRBIN/git-new"
	git switch -c "\$1"
	git push -u origin "\$1"
	EOF

	set_exit_immediately "$USRBIN/git-supplant"
	cat <<- EOF >> "$USRBIN/git-supplant"
	git push -d origin "\$(git rev-parse --abbrev-ref HEAD)"
	git branch --unset-upstream
	git branch -D "\$1"
	git branch -M "\$1"
	git push --force --set-upstream origin "\$1"
	EOF

	set_exit_immediately "$USRBIN/git-zap"
	cat <<- EOF >> "$USRBIN/git-zap"
	git branch -D "\$@"
	git push -d origin "\$@"
	EOF

	chmod +x "$USRBIN"/git-*
fi

if [ -r ~/.bashrc ]; then
	if ! grep -q 'unset HISTFILE' ~/.bashrc; then
		cat <<- EOF >> ~/.bashrc

		unset HISTFILE
		EOF
	fi
fi

touch ~/.hushlogin

if [ -x "$BIN/tmux" ]; then
	cat <<- EOF > ~/.tmux.conf
	bind -N 'Split window horizontally: 80-columns pane' '\`' splitw -hl 80
	unbind C-z

	set -g renumber-windows on

	source -q ~/.tmux_local.conf
	EOF
fi

VIMCONFIG="$HOME/.vim"
mkdir -p "$VIMCONFIG"

if [ -x "$BIN/vi" ]; then
	VIMCONFIG="$HOME/.vim"
	mkdir -p "$VIMCONFIG"

	cat <<- EOF > "$VIMCONFIG/vimrc"
	nnoremap q <Nop>
	nnoremap K <Nop>

	set hlsearch
	set incsearch
	set nowrap
	set shortmess-=S
	set splitbelow
	set splitright
	set viminfo=

	if filereadable('/usr/share/doc/fzf/examples/fzf.vim')
	  source /usr/share/doc/fzf/examples/fzf.vim
	endif

	runtime local.vim
	EOF
fi

if [ "$ID" = freebsd ]; then
	if [ ! -f ~/.nexrc ]; then
		printf 'set ai ruler\n' > ~/.nexrc
	fi
	if [ -r ~/.profile ]; then
		sed -i '' '/fortune/ { /^#/!s/^/# /; }' ~/.profile
	fi
	if [ -r ~/.shrc ]; then
		if ! grep -q '# gh-nate/dots' ~/.shrc; then
			cat <<- EOF >> ~/.shrc

			# gh-nate/dots

			alias /=/usr/libexec/flua
			HISTFILE=
			export LESSHISTFILE=-
			rm -f ~/.lldb/lldb-widehistory ~/.lldb/lua-widehistory
			[ -f ~/.shrc_local ] && . ~/.shrc_local
			EOF
		fi
	fi

	printf 'done\n'
	exit
fi

cat << EOF > ~/.zlogout
rm -f \\
	~/.{bash,python}_history \\
	~/.lesshst

if [[ -r ~/.zlogout_local ]]; then . ~/.zlogout_local; fi
EOF

cat << EOF > ~/.zshrc
alias ll='ls -hAlp'

autoload -U compinit
compinit

bindkey -e

export EDITOR=vi
export GOBIN=$USRBIN
export LESSHISTFILE=-
export PAGER=less

typeset -U path PATH
path=(\$GOBIN \$path)

export PATH

function u {
	sudo apt-get update
	apt list --upgradable
	sudo apt-get upgrade
}

function / {
	if [[ ! -x $BIN/python3 ]]; then
		sudo apt-get update
		sudo apt-get install -y python3-minimal
	fi
	python3 -q
}

if [[ -d /usr/share/doc/fzf/examples ]]; then
	. /usr/share/doc/fzf/examples/completion.zsh
	. /usr/share/doc/fzf/examples/key-bindings.zsh
fi

setopt interactive_comments
setopt print_exit_value

if [[ -r ~/.zshrc_local ]]; then . ~/.zshrc_local; fi
EOF

printf 'done\n'
