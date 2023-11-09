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

cat << EOF > ~/.irbrc
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

printf 'done\n'
