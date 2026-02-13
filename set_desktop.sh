#!/bin/sh

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

set -e

gsettings set org.gnome.mutter center-new-windows true

if command -v ghostty > /dev/null; then
	mkdir -p ~/.config/ghostty
	cat <<- EOF > ~/.config/ghostty/config
	adjust-cell-height = 15%
	font-family = Ubuntu Mono
	font-size = 14
	theme = light:Rose Pine Dawn,dark:Rose Pine
	window-padding-x = 10
	window-padding-y = 10
	EOF
fi

if command -v flatpak > /dev/null; then
	if flatpak info dev.zed.Zed 2> /dev/null; then
		mkdir -p ~/.var/app/dev.zed.Zed/config/zed/
		cat <<- EOF > ~/.var/app/dev.zed.Zed/config/zed/settings.json
{
    "terminal": {
        "font_family": "Ubuntu Mono"
    },
    "ui_font_family": "Ubuntu Sans",
    "buffer_font_family": "Ubuntu Mono",
    "ui_font_size": 16,
    "buffer_font_size": 15,
    "theme": {
        "mode": "system",
        "light": "Rosé Pine Dawn",
        "dark": "Rosé Pine",
    },
    "telemetry": {
        "diagnostics": false,
        "metrics": false,
    },
}
		EOF
	fi
fi

printf 'done\n'
