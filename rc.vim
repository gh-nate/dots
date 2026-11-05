" Copyright (c) 2026 gh-nate
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

map q :checktime<Cr>
if has("extra_search")
  set hlsearch
endif

map K <Nop>

if has("syntax")
  syntax enable
endif
filetype plugin indent on

if has("viminfo")
  set viminfofile=NONE
endif

set autoread
set backspace=indent,eol,start
set splitbelow
set splitright
set nowrap

if executable("fzy")
  function! FzyCommand(choice_command, vim_command)
    try
      let output = system(a:choice_command . " | fzy ")
    catch /Vim:Interrupt/
      " Swallow errors from ^C, allow redraw! below
    endtry
    redraw!
    if v:shell_error == 0 && !empty(output)
      exec a:vim_command . ' ' . output
    endif
  endfunction

  nnoremap <leader>e :call FzyCommand("find . -type f", ":e")<cr>
  nnoremap <leader>v :call FzyCommand("find . -type f", ":vs")<cr>
  nnoremap <leader>s :call FzyCommand("find . -type f", ":sp")<cr>
endif

runtime local.vim
