" ============================================================================
" File:        relnumbar.vim
" Description: Vim plugin that creates a relative number window to the left,
"              allowing both relative and normal numbering at the same time.
" Author:      Barry Arthur <barry.arthur at gmail dot com>
" Last Change: 19 August, 2010
"
" Licensed under the same terms as Vim itself.
" ============================================================================
let s:RelNumBar_version = '0.0.1'

let g:relnumbar_enabled = 0
let g:relnumbar_window = 0
let g:relnumbar_buffer = 0

" Private Functions{{{1
function! RelNumBar()
  " jump to the first line of the file, otherwise our bound
  " relative-line-number window won't scroll above current cursor position
  let curpos = getpos('.')
  call setpos('.', [0, 1, 1, 0])

  let numlines = line('$')

  " create a new window above the current one and make it a 'scratch' buffer
  vnew RelNumBar
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile

  " insert numlines worth of <CR>
  call append('$', repeat([''], numlines))

  vertical resize 5
  setlocal relativenumber
  setlocal cursorline
  setlocal foldcolumn=0

  let g:relnumbar_window = winnr()
  let g:relnumbar_buffer = bufnr('%')

  " bind the window we came from to scroll with the column ruler
  setlocal scrollbind
  setlocal scrollopt=ver,jump
  wincmd p
  setlocal number
  setlocal scrollbind
  setlocal scrollopt=ver,jump
  call setpos('.', curpos)

  augroup RelNumBar
    autocmd!
    autocmd CursorMoved,CursorMovedI * call UpdateRelNumBarCursor()
    " TODO: This is NOT working right... it leaves an empty buffer on  :q
    "autocmd BufLeave <buffer> call RelNumBarClose() | bdelete
    "autocmd BufEnter <buffer> call RelNumBarReOpen()
  augroup END
endfunction

" CursorHold callback to update the column-ruler window whenever we move our
" cursor in the bound (original) window.
function! UpdateRelNumBarCursor()
  let newline = line('.')
  let thiswin = winnr()
  exe g:relnumbar_window . "wincmd w"
  vertical resize 5
  call setpos('.', [0, newline, 0, 0])
  exe thiswin . "wincmd w"
  " Kill vim if RelNumBar's window is the last standing.
  if bufwinnr(bufnr('%')) == 1 && winnr('$') == 1 && bufname('%') == 'RelNumBar'
    exit
  endif

endfunction

function! RelNumBarReOpen()
  if g:relnumbar_enabled
    call RelNumBar()
  endif
endfunction

function! RelNumBarClose()
  let g:relnumbar_enabled = 0
  echo g:relnumbar_buffer
  exe "bdelete " . g:relnumbar_buffer
  augroup RelNumBar
    autocmd!
  augroup END
endfunction

function! ToggleRelNumBar()
  let g:relnumbar_enabled = ! g:relnumbar_enabled
  if g:relnumbar_enabled
    call RelNumBar()
  else
    call RelNumBarClose()
  endif
endfunction

" Maps{{{1
nnoremap <leader>N :call ToggleRelNumBar()<CR>

" Commands{{{1
command! -nargs=0 RelNumBar call RelNumBar()
command! -nargs=0 ToggleRelNumBar call ToggleRelNumBar()
