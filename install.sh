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

if [ ! -f /etc/debian_version ] && [ ! -f /etc/arch-release ]; then
	printf 'unsupported operating system\n' >&2
	exit 1
fi

USRBIN="$HOME/.local/bin"

if [ -x /usr/bin/git ]; then
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

	set_exit_immediately "$USRBIN/git-bs"
	cat <<- EOF >> "$USRBIN/git-bs"
	if [ "\$3" = -f ]
	then git show "\$(git blame -L\$1,+1 \$2|awk '{print \$1}')"
	else git blame -L\$1,+1 \$2
	fi
	EOF

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

if [ -f /etc/debian_version ]; then
	touch ~/.hushlogin
fi

VIMCONFIG="$HOME/.vim"
mkdir -p "$VIMCONFIG"

if [ -f /etc/arch-release ]; then
	mkdir -p "$USRBIN"
	ln -fs /usr/bin/vim "$USRBIN/vi"
fi

cat << EOF > "$VIMCONFIG/vimrc"
nmap \` :vert ter ++cols=80<CR>
nmap t :tab ter<CR>

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

cat << EOF > ~/.zlogout
rm -f ~/.bash_history ~/.lesshst

if [[ -r ~/.zlogout_local ]]; then . ~/.zlogout_local; fi
EOF

cat << EOF > ~/.zshrc
alias ll='ls -hAlp'

autoload -U compinit
compinit

bindkey -e

if [[ -f /etc/arch-release ]]; then
	export EDITOR=vim
elif [[ -f /etc/debian_version ]]; then
	export EDITOR=vi
fi
export LESSHISTFILE=-
export PAGER=less

typeset -U path PATH
path=(\$HOME/.local/bin \$path)

export PATH

if [[ -d /usr/share/doc/fzf/examples ]]; then
	. /usr/share/doc/fzf/examples/completion.zsh
	. /usr/share/doc/fzf/examples/key-bindings.zsh
elif [[ -d /usr/share/fzf ]]; then
	. /usr/share/fzf/completion.zsh
	. /usr/share/fzf/key-bindings.zsh
fi

setopt interactive_comments
setopt print_exit_value

if [[ -r ~/.zshrc_local ]]; then . ~/.zshrc_local; fi
EOF

printf 'done\n'
