#!/bin/sh

# Copyright (c) 2023 gh-nate
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

while getopts ghiv o; do
	case "$o" in
		g) INSTALL_GIT=1 ;;
		i) INSTALL_IRB=1 ;;
		v) INSTALL_VIM=1 ;;
		h|?) HELP=1 ;;
	esac
done

if [ "$HELP" ]; then
	cat <<- EOF
	usage: install.sh [-g] [-h] [-i] [-v]

	-g install git configuration
	-h print this help text
	-i install irb configuration
	-v install vim configuration
	EOF
	exit 129
fi

if [ -r /etc/os-release ]; then
	# shellcheck disable=SC1091
	. /etc/os-release
fi

case "$ID" in
	freebsd)
		PKGBIN='/usr/local/bin'
		USRBIN="$HOME/bin"
		;;
	ubuntu)
		PKGBIN='/usr/bin'
		USRBIN="$HOME/.local/bin"
		;;
	*)
		printf 'Unsupported OS\n' >&2
		exit 1
		;;
esac

if [ -z "$INSTALL_GIT" ] && [ -x "$PKGBIN/git" ]; then
	INSTALL_GIT=1
fi

if [ "$INSTALL_GIT" ]; then
	git config --global alias.fresh 'commit --amend --date=now'
	git config --global alias.lol 'log --oneline'

	if [ ! -d "$USRBIN" ]; then mkdir -p "$USRBIN"; fi

	cat <<- EOF > "$USRBIN/git-new"
	set -e

	git switch -c "\$1"
	git push -u origin "\$1"
	EOF
	chmod +x "$USRBIN/git-new"

	cat <<- EOF > "$USRBIN/git-supplant"
	set -e

	git push -d origin "\$(git rev-parse --abbrev-ref HEAD)"
	git branch --unset-upstream
	git branch -D "\$1"
	git branch -M "\$1"
	git push --force --set-upstream origin "\$1"
	EOF
	chmod +x "$USRBIN/git-supplant"

	cat <<- EOF > "$USRBIN/git-zap"
	set -e

	git branch -D "\$@"
	git push -d origin "\$@"
	EOF
	chmod +x "$USRBIN/git-zap"
fi

if [ -z "$INSTALL_IRB" ] && [ -x "$PKGBIN/irb" ]; then
	INSTALL_IRB=1
fi

if [ "$INSTALL_IRB" ]; then
	cat <<- EOF > ~/.irbrc
	IRB.conf[:PROMPT_MODE] = :SIMPLE
	IRB.conf[:SAVE_HISTORY] = nil

	class Integer
	  def bin(human_readable = false)
	    result = to_s(2)
	    result.chunk if human_readable
	    result
	  end
	  def hex(human_readable = false)
	    result = to_s(16)
	    result.chunk if human_readable
	    result
	  end
	end

	class String
	  def chunk
	    zfill(4)
	    (1...length / 4).each { |n| insert(n * 4 + n - 1, " ") }
	  end
	  def zfill(n)
	    remainder = length % n
	    remainder.zero? ? self : prepend("0" * (n - remainder))
	  end
	end
	EOF
fi

if [ -z "$INSTALL_VIM" ] && [ -x "$PKGBIN/vim" ]; then
	INSTALL_VIM=1
fi

if [ "$INSTALL_VIM" ]; then
	CONFIG="$HOME/.vim"
	if [ ! -d "$CONFIG" ]; then mkdir "$CONFIG"; fi

	cat <<- EOF > "$CONFIG/vimrc"
	nnoremap q <Nop>
	nnoremap K <Nop>

	set hlsearch
	set incsearch
	set nowrap
	set splitbelow
	set splitright
	set viminfo=

	runtime local.vim
	EOF
fi

if [ "$ID" = ubuntu ]; then
	if ! grep -q 'unset HISTFILE' ~/.bashrc; then
		cat <<- EOF >> ~/.bashrc

		unset HISTFILE
		EOF
	fi
fi

touch ~/.hushlogin

if [ "$ID" = freebsd ]; then
	cat <<- EOF > ~/.nexrc
	set autoindent
	set ruler
	EOF

	cat <<- EOF > ~/.profile
	export EDITOR=vi
	export ENV="\$HOME/.shrc"
	export PAGER=less

	# Query terminal size; useful for serial links.
	if [ -x /usr/bin/resizewin ]; then /usr/bin/resizewin -z; fi

	if [ -r "\$HOME/.profile_local" ]; then . "\$HOME/.profile_local"; fi
	EOF

	cat <<- EOF > ~/.shrc
	alias ll='ls -hAlp'

	HISTFILE=
	rm -f "\$HOME/.sh_history"

	export LESSHISTFILE=-
	rm -f "\$HOME/.lesshst"

	truncate -c -s 0 "\$HOME/.lldb/lldb-widehistory" "\$HOME/.lldb/lua-widehistory"

	if [ -r "\$HOME/.shrc_local" ]; then . "\$HOME/.shrc_local"; fi
	EOF
fi

cat << EOF > ~/.tmux.conf
bind -N 'Split window horizontally: 80-columns pane' '^' splitw -hl 80
unbind C-z

set -g renumber-windows on

source -q ~/.tmux_local.conf
EOF

cat << EOF > ~/.zlogout
rm -f "\$HOME/.lesshst"

truncate -c -s 0 "\$HOME"/.lldb/{lldb,lua}-widehistory

if [[ -r "\$HOME/.zlogout_local" ]]; then . "\$HOME/.zlogout_local"; fi
EOF

cat << EOF > ~/.zprofile
export EDITOR=vi
export PAGER=less

# Query terminal size; useful for serial links.
if [[ -x /usr/bin/resizewin ]]; then /usr/bin/resizewin -z; fi

if [[ -r "\$HOME/.zprofile_local" ]]; then . "\$HOME/.zprofile_local"; fi
EOF

cat << EOF > ~/.zshrc
alias ll='ls -hAlp'

autoload -U compinit
compinit

bindkey -e

export LESSHISTFILE=-

EOF

if [ "$ID" = ubuntu ]; then
	TAB=$(printf '\t')
	cat <<- EOF >> ~/.zshrc
	USRBIN="\$HOME/.local/bin"
	if [[ -d "\$USRBIN" ]] && [[ ! "\$PATH" =~ "\$USRBIN" ]]; then
	${TAB}export PATH="\$USRBIN:\$PATH"
	fi
	unset USRBIN

	EOF
fi

cat << EOF >> ~/.zshrc
setopt interactive_comments
setopt print_exit_value

if [[ -r "\$HOME/.zshrc_local" ]]; then . "\$HOME/.zshrc_local"; fi
EOF

rm -f ~/.cshrc ~/.login

printf 'done\n'
