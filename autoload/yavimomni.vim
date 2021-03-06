"=============================================================================
" FILE: autoload/yavimomni.vim
" AUTHOR: sgur <sgurrr+vim@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim


" The Other
call yavimomni#ex_command#init()
call yavimomni#user_command#init()
" Just after :lockvar, :unlockvar, :let :unlet
" After :if, :while :for
call yavimomni#variable#init()
call yavimomni#script_variable#init()
" After :call, :return, :let {var}=
" Parameters
call yavimomni#function#init()
call yavimomni#user_function#init()
" After :set, :let &{var}=
call yavimomni#option#init()
" After :map
call yavimomni#map_argument#init()
" has()
call yavimomni#feature#init()


function! yavimomni#complete(findstart, base)
  if a:findstart
    let start = col('.') - 1
    let line = getline('.')
    while start > 0 && line[start-1] =~ '\k\|[<>]'
      let start -= 1
    endwhile
    return start
  else
    let sentence = s:concat_lines('.', '.')
    let _ = s:get_candidates_by_context(sentence, a:base)
    return filter(_, 's:start_with(v:val, a:base)')
  endif
endfunction

function! yavimomni#candidates(base)
  let sentence = s:concat_lines('.', '.')
  return s:get_candidates_by_context(sentence, a:base)
endfunction

function! s:start_with(haystack, needle)
  return type(a:haystack) == type({})
        \ ? !stridx(a:haystack.word, a:needle)
        \ : !stridx(a:haystack, a:needle)
endfunction


function! s:concat_lines(line, col)
  let lnum = (type(a:line) == type(0)) ? a:line : line(a:line)
  let col  = (type(a:col) == type(0))  ? a:col  : line(a:col)
  let line = getline(lnum)[:col-1]
  let match = matchstr(line, '^\s*\\\zs.\+$')
  while match != '' && lnum > 1
    let lnum -= 1
    let line = getline(lnum) . match
    let match = matchstr(line, '^\s*\\\zs.\+$')
  endwhile
  return line
endfunction


function! s:get_candidates_by_context(line, arglead)
  let _ = []
  if a:line =~ "has(['\"]"
    " Features
    call extend(_, yavimomni#feature#get(a:arglead))
  elseif a:line =~ '\<\%(set\s\+\|let &\)$'
    " Options
    call extend(_, yavimomni#option#get(a:arglead))
  elseif a:line =~ '\<\%(' . join([
        \ 's\?map', 'map!', '[nvxoilc]m\%(ap\)\?', 'no\%(remap\)\?',
        \ '\%(nn\|vn\|xn\)\%(oremap\)\?', 'snor\%(emap\)\?',
        \ '\%(ono\|no\|ino\)\%(remap\)\?', 'ln\%(oremap\)\?',
        \ 'cno\%(remap\)\?',
        \ ], '\|') . '\)\>'
    " Map arguments
    call extend(_, yavimomni#map_argument#get(a:arglead))
  endif
  " Ex commands
  call extend(_, yavimomni#ex_command#get(a:arglead))
  call extend(_, yavimomni#function#get(a:arglead))
  call extend(_, yavimomni#script_variable#get(a:arglead))
  call extend(_, yavimomni#user_command#get(a:arglead))
  call extend(_, yavimomni#user_function#get(a:arglead))
  call extend(_, yavimomni#variable#get(a:arglead))
  return _
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
