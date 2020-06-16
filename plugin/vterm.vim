" if !has('nvim')
"     finish
" endif

if exists('g:loaded_vterm')
    finish 
endif

let g:loaded_vterm = 1

let g:vterm_map_toggleterm = get(g:, 'vterm_map_toggleterm', '<C-t>')
let g:vterm_map_togglefocus = get(g:, 'vterm_map_togglefocus', '<C-q>')
let g:vterm_win_height = get(g:, 'vterm_win_height', 8)

if has('nvim')
    let s:term_start = 'terminal'
    let s:term_insert = 'startinsert!'
else
    let s:term_start = 'terminal ++curwin ++kill=kill'
    let s:term_insert = 'call feedkeys("i")'
    silent !stty -ixon > /dev/null 2>/dev/null
endif

function! VTermOpenWindow()
    let t:vterm_show = 1
    let t:vterm_last_win = win_getid() 
    bo split
    exe "resize " . t:vterm_win_height 
    if exists("g:vterm_bufname")
        exe "buffer" g:vterm_bufname
        exe s:term_insert
    else
        exe s:term_start
        exe "set ft=vterm"
        let g:vterm_bufname = bufname("%")
    endif
endf

function! VTermHideWindow()
    let t:vterm_show = 0 
    let t:vterm_win_height = winheight(bufwinnr(g:vterm_bufname))
    if bufwinnr(g:vterm_bufname) == winnr()
        exe win_id2win(t:vterm_last_win) . "wincmd w"
    endif
    exe bufwinnr(g:vterm_bufname)"hide"
endfunction

function! VTermCloseWindow()
    let t:vterm_show = 0
    if &filetype == 'vterm' 
        q 
    endif
endfu


function! VTermToggleTerminal() 
    if exists("t:vterm_show")
        if (t:vterm_show == 0)
            " Show terminal window
            call VTermOpenWindow()
        else 
            " Hide terminal window
            call VTermHideWindow()
        endif
    else 
        let t:vterm_win_height = g:vterm_win_height
        call VTermOpenWindow()
    endif
endfunction

function! VTermToggleFocus()
    if (exists("g:vterm_bufname") && t:vterm_show == 1)
        if winnr() == bufwinnr(g:vterm_bufname)
            " Leave vterm window
            exe win_id2win(t:vterm_last_win) . "wincmd w"
        else
            " Focus vterm window
            let t:vterm_last_win = win_getid() 
            exe bufwinnr(g:vterm_bufname) . "wincmd w"
            exe s:term_insert
        endif
    endif
endfunction

function! VTermClose()
    if (exists("g:vterm_bufname"))
        if (t:vterm_show == 1)
            call VTermHideWindow()
            let t:vterm_win_height = g:vterm_win_height 
        endif 
        exe "bdelete! " . g:vterm_bufname 
        unlet g:vterm_bufname 
    endif 
endfunction

exe 'tnoremap ' . vterm_map_toggleterm . ' <C-\><C-n>:call VTermToggleTerminal()<CR>'
exe 'nnoremap ' . vterm_map_toggleterm . ' :call VTermToggleTerminal()<CR>'
exe 'tnoremap ' . vterm_map_togglefocus . ' <C-\><C-n>:call VTermToggleFocus()<CR>'
exe 'nnoremap ' . vterm_map_togglefocus . ' :call VTermToggleFocus()<CR>'
augroup VTERM
    au FileType vterm set nobuflisted
    au bufenter     * if (winnr("$") == 1 && &buftype ==# 'terminal' ) | q! | endif
    au BufWinLeave  * if &filetype == "vterm" | let t:vterm_show = 0 | endif 
    au VimLeave     * VTermClose
augroup end
"autocmd BufDelete * if &buftype == "terminal" | unlet g:vterm_bufname | endif 

if has('nvim')
    augroup VTERM_NVIM
        " au TermClose    * call VTermHideWindow() | unlet g:vterm_bufname
        au TermClose    * call VTermCloseWindow() | unlet! g:vterm_bufname
    augroup end
endif

command! -n=0 -bar VTermToggleTerminal call VTermToggleTerminal()
command! -n=0 -bar VTermToggleFocus call VTermToggleFocus() 
command! -n=0 -bar VTermClose call VTermClose() 
