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
EOF

cat << EOF > ~/.shrc
HISTFILE=
rm -f "\$HOME/.sh_history"

export LESSHISTFILE=-
rm -f "\$HOME/.lesshst"

for REPL in lldb lua; do
        REPLHISTFILE="\$HOME/.lldb/\$REPL-widehistory"
        if [ -s "\$REPLHISTFILE" ]; then
                : > "\$REPLHISTFILE"
        fi
done
unset REPL REPLHISTFILE

if [ -f "\$HOME/.shrc_local" ]; then . "\$HOME/.shrc_local"; fi
EOF

cat << EOF > ~/.zlogout
rm -f "\$HOME/.lesshst"

for REPL in lldb lua; do
        REPLHISTFILE="\$HOME/.lldb/\$REPL-widehistory"
        if [[ -s "\$REPLHISTFILE" ]]; then
                : > "\$REPLHISTFILE"
        fi
done

if [[ -f "\$HOME/.zlogout_local" ]]; then . "\$HOME/.zlogout_local"; fi
EOF

cat << EOF > ~/.zprofile
export EDITOR=vi
export PAGER=less

# Query terminal size; useful for serial links.
if [[ -x /usr/bin/resizewin ]]; then /usr/bin/resizewin -z; fi
EOF

cat << EOF > ~/.zshrc
export LESSHISTFILE=-

if [[ -f "\$HOME/.zshrc_local" ]]; then . "\$HOME/.zshrc_local"; fi
EOF

rm -f ~/.cshrc ~/.login

printf 'done\n'
