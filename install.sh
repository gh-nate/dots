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

while getopts ghrv o; do
	case "$o" in
		g) INSTALL_GIT=1 ;;
		r) INSTALL_RUBY=1 ;;
		v) INSTALL_VIM=1 ;;
		h|?) HELP=1 ;;
	esac
done

if [ "$HELP" ]; then
	cat <<- EOF
	usage: install.sh [-g] [-h] [-r] [-v]

	-g install git configuration
	-h print this help text
	-r install ruby configuration
	-v install vim configuration
	EOF
	exit 129
fi

if [ -z "$INSTALL_GIT" ] && [ -x /usr/local/bin/git ]; then
	INSTALL_GIT=1
fi

if [ "$INSTALL_GIT" ]; then
	git config --global alias.fresh 'commit --amend --date=now'
	git config --global alias.lol 'log --oneline'

	BIN="$HOME/bin"
	if [ ! -d "$BIN" ]; then mkdir "$BIN"; fi

	cat <<- EOF > "$BIN/git-new"
	set -e

	git switch -c "\$1"
	git push -u origin "\$1"
	EOF
	chmod +x "$BIN/git-new"

	cat <<- EOF > "$BIN/git-supplant"
	set -e

	git push -d origin "\$(git rev-parse --abbrev-ref HEAD)"
	git branch --unset-upstream
	git branch -D "\$1"
	git branch -M "\$1"
	git push --force --set-upstream origin "\$1"
	EOF
	chmod +x "$BIN/git-supplant"

	cat <<- EOF > "$BIN/git-zap"
	set -e

	git branch -D "\$@"
	git push -d origin "\$@"
	EOF
	chmod +x "$BIN/git-zap"
fi

if [ -z "$INSTALL_RUBY" ] && [ -x /usr/local/bin/irb ]; then
	INSTALL_RUBY=1
fi

if [ "$INSTALL_RUBY" ]; then
	cat <<- EOF > ~/.irbrc
	IRB.conf[:PROMPT_MODE] = :SIMPLE
	IRB.conf[:SAVE_HISTORY] = nil

	class Integer
	  def bin(human_readable = false)
	    result = to_s(2)
	    human_readable ? result.chunk : result
	  end
	  def hex(human_readable = false)
	    result = to_s(16)
	    human_readable ? result.chunk : result
	  end
	end

	class String
	  def chunk
	    zfill(4)
	    (1...length / 4).each { |n| insert(n * 4 + n - 1, " ") }
	    self
	  end
	  def zfill(n)
	    remainder = length % n
	    remainder.zero? ? self : prepend("0" * (n - remainder))
	  end
	end
	EOF
fi

if [ -z "$INSTALL_VIM" ] && [ -x /usr/local/bin/vim ]; then
	INSTALL_VIM=1
fi

if [ "$INSTALL_VIM" ]; then
	CONFIG="$HOME/.vim"
	if [ ! -d "$CONFIG" ]; then mkdir "$CONFIG"; fi

	cat <<- EOF > "$CONFIG/vimrc"
	set splitbelow
	set splitright
	set viminfo=
	EOF
fi

touch ~/.hushlogin

cat << EOF > ~/.nexrc
set autoindent
set ruler
EOF

cat << EOF > ~/.profile
export EDITOR=vi
export ENV="\$HOME/.shrc"
export PAGER=less

# Query terminal size; useful for serial links.
if [ -x /usr/bin/resizewin ]; then /usr/bin/resizewin -z; fi

if [ -r "\$HOME/.profile_local" ]; then . "\$HOME/.profile_local"; fi
EOF

cat << EOF > ~/.shrc
alias ll='ls -hAlp'

HISTFILE=
rm -f "\$HOME/.sh_history"

export LESSHISTFILE=-
rm -f "\$HOME/.lesshst"

truncate -c -s 0 "\$HOME/.lldb/lldb-widehistory" "\$HOME/.lldb/lua-widehistory"

if [ -r "\$HOME/.shrc_local" ]; then . "\$HOME/.shrc_local"; fi
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

setopt interactive_comments
setopt print_exit_value

if [[ -r "\$HOME/.zshrc_local" ]]; then . "\$HOME/.zshrc_local"; fi
EOF

rm -f ~/.cshrc ~/.login

printf 'done\n'
