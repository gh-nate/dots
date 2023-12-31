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
	# shellcheck disable=SC1091
	. /etc/os-release
fi

if [ "$ID" = debian ] || [ "$ID_LIKE" = debian ]; then
	USRBIN="$HOME/.local/bin"
else
	if [ -z "$ID" ]; then ID=Unknown; fi
	printf 'Unsupported OS: %s\n' "$ID" >&2
	exit 1
fi

if [ -x /usr/bin/git ]; then
	GITCONFIG="$HOME/.config/git"
	if [ ! -d "$GITCONFIG" ]; then mkdir -p "$GITCONFIG"; fi

	touch "$GITCONFIG/config"
	git config --global alias.fresh 'commit --amend --date=now'
	git config --global alias.lol 'log --oneline'

	cat <<- EOF > "$GITCONFIG/ignore"
	*.swp
	EOF

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

if [ -x /usr/bin/irb ]; then
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

if [ -r ~/.bashrc ]; then
	if ! grep -q 'unset HISTFILE' ~/.bashrc; then
		cat <<- EOF >> ~/.bashrc

		unset HISTFILE
		EOF
	fi
fi

touch ~/.hushlogin

cat << EOF > ~/.tmux.conf
bind -N 'Split window horizontally: 80-columns pane' '^' splitw -hl 80
unbind C-z

set -g renumber-windows on

source -q ~/.tmux_local.conf
EOF

VIMCONFIG="$HOME/.vim"
if [ ! -d "$VIMCONFIG" ]; then mkdir "$VIMCONFIG"; fi

cat << EOF > "$VIMCONFIG/vimrc"
nnoremap q <Nop>
nnoremap K <Nop>

set hlsearch
set incsearch
set nowrap
set splitbelow
set splitright
set viminfo=

if filereadable('/usr/share/doc/fzf/examples/fzf.vim')
  source /usr/share/doc/fzf/examples/fzf.vim
endif

runtime local.vim
EOF

cat << EOF > ~/.zlogout
rm -f ~/.bash_history ~/.lesshst

if [[ -r ~/.zlogout_local ]]; then . ~/.zlogout_local; fi
EOF

cat << EOF > ~/.zprofile
export EDITOR=vi
export PAGER=less

if [[ -r ~/.zprofile_local ]]; then . ~/.zprofile_local; fi
EOF

cat << EOF > ~/.zshrc
alias ll='ls -hAlp'

autoload -U compinit
compinit

bindkey -e

export LESSHISTFILE=-

if [[ -d $USRBIN ]] && [[ ! "\$PATH" =~ $USRBIN ]]; then
	export PATH="$USRBIN:\$PATH"
fi

if [[ -d /usr/share/doc/fzf/examples ]]; then
	. /usr/share/doc/fzf/examples/completion.zsh
	. /usr/share/doc/fzf/examples/key-bindings.zsh
fi

setopt interactive_comments
setopt print_exit_value

if [[ -r ~/.zshrc_local ]]; then . ~/.zshrc_local; fi
EOF

printf 'done\n'
