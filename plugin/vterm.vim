if !has('nvim')
    finish
endif

if exists('g:loaded_vterm')
    finish 
endif

let g:loaded_vterm = 1

let g:vterm_map_toggleterm = get(g:, 'vterm_map_toggleterm', '<C-t>')
let g:vterm_map_togglefocus = get(g:, 'vterm_map_togglefocus', '<C-q>')
let g:vterm_win_height = get(g:, 'vterm_win_height', 8)

function! VTermOpenWindow()
    let t:vterm_show = 1
    let t:vterm_last_win = win_getid() 
    bo split
    exe "resize " . t:vterm_win_height 
    if exists("g:vterm_bufname")
        exe "buffer" g:vterm_bufname
    else
        terminal
        exe "set ft=vterm"
        let g:vterm_bufname = bufname("%")
    endif
    startinsert!
endf

function! VTermHideWindow()
    let t:vterm_show = 0 
    let t:vterm_win_height = winheight(bufwinnr(g:vterm_bufname))
    if bufwinnr(g:vterm_bufname) == winnr()
        exe win_id2win(t:vterm_last_win) . "wincmd w"
    endif
    exe bufwinnr(g:vterm_bufname)"hide"
endfunction

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
            startinsert!
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
    au bufenter     * if (winnr("$") == 1 && &buftype ==# 'terminal' ) | q | endif
    au BufWinLeave  * if &filetype == "vterm" | let t:vterm_show = 0 | endif 
    au TermClose    * call VTermHideWindow() | unlet g:vterm_bufname
    au VimLeavePre  * VTermClose
augroup end
"autocmd BufDelete * if &buftype == "terminal" | unlet g:vterm_bufname | endif 

command! -n=0 -bar VTermToggleTerminal call VTermToggleTerminal()
command! -n=0 -bar VTermToggleFocus call VTermToggleFocus() 
command! -n=0 -bar VTermClose call VTermClose() 
