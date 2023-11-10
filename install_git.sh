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

git config --global alias.fresh 'commit --amend --date=now'
git config --global alias.lol 'log --oneline'

BIN="$HOME/bin"
if ! test -d "$BIN"; then mkdir "$BIN"; fi

cat << EOF > "$BIN/git-new"
set -e

git switch -c "\$1"
git push -u origin "\$1"
EOF
chmod +x "$BIN/git-new"

cat << EOF > "$BIN/git-supplant"
set -e

git push -d origin "\$(git rev-parse --abbrev-ref HEAD)"
git branch --unset-upstream
git branch -D "\$1"
git branch -M "\$1"
git push --force --set-upstream origin "\$1"
EOF
chmod +x "$BIN/git-supplant"

cat << EOF > "$BIN/git-zap"
set -e

git branch -D "\$@"
git push -d origin "\$@"
EOF
chmod +x "$BIN/git-zap"

printf 'done\n'
