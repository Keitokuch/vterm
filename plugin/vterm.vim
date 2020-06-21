if exists('g:loaded_vterm')
    finish 
endif

let g:loaded_vterm = 1

let g:vterm_map_toggleterm = get(g:, 'vterm_map_toggleterm', '<C-t>')
let g:vterm_map_togglefocus = get(g:, 'vterm_map_togglefocus', '<C-q>')
let g:vterm_win_height = get(g:, 'vterm_win_height', 8)

if has('nvim')
    " Neovim
    let s:term_start = 'terminal'
    let s:term_insert = 'startinsert!'
    let s:nvim_insert = 'startinsert!'
else
    "  Vim
    let s:term_start = 'terminal ++curwin ++kill=kill'
    let s:term_insert = 'call feedkeys("i")'
    let s:nvim_insert = ''
    silent !stty -ixon > /dev/null 2>/dev/null
endif

function! VTermOpenWindow()
    let t:vterm_show = 1
    let t:vterm_last_win = win_getid() 
    bo split
    exe "resize " . t:vterm_win_height 
    if exists("t:vterm_bufname")
        exe "buffer" t:vterm_bufname
        exe s:term_insert
    else
        " Create buffer
        exe s:term_start
        exe "set ft=vterm"
        let t:vterm_bufname = bufname("%")
        exe s:nvim_insert
    endif
endf

function! VTermHideWindow()
    let t:vterm_show = 0 
    if exists("t:vterm_bufname")
        let t:vterm_win_height = winheight(bufwinnr(t:vterm_bufname))
        if bufwinnr(t:vterm_bufname) == winnr()
            exe win_id2win(t:vterm_last_win) . "wincmd w"
        endif
        exe bufwinnr(t:vterm_bufname)"hide"
    endif
endfunction

function! VTermToggleTerminal() 
    if get(t:, 'vterm_show', 0) == 0
        call VTermOpenWindow()
    else 
        call VTermHideWindow()
    endif
endfunction

function! VTermToggleFocus()
    if (exists("t:vterm_bufname") && t:vterm_show == 1)
        if winnr() == bufwinnr(t:vterm_bufname)
            " Leave vterm window
            exe win_id2win(t:vterm_last_win) . "wincmd w"
        else
            " Focus vterm window
            let t:vterm_last_win = win_getid() 
            exe bufwinnr(t:vterm_bufname) . "wincmd w"
            exe s:term_insert
        endif
    endif
endfunction

function! VTermClose()
    call VTermHideWindow()
    call VTermDestroy()
    if (exists("t:vterm_bufname"))
        if (t:vterm_show == 1)
            call VTermHideWindow()
            let t:vterm_win_height = g:vterm_win_height 
        endif 
    endif 
endfunction

function! VTermDestroy()
    if exists("t:vterm_bufname")
        if bufexists(t:vterm_bufname) 
            exe "bd! " . bufnr(t:vterm_bufname)
        endif
        unlet t:vterm_bufname
    endif
endfu

augroup VTERM
    au FileType vterm set nobuflisted
    au TabEnter     * let t:vterm_win_height = g:vterm_win_height
    au VimEnter     * let t:vterm_win_height = g:vterm_win_height
    au bufenter     * if (winnr("$") == 1 && &buftype ==# 'terminal' ) | q! | endif
    au BufWinLeave  * if &filetype == "vterm" | let t:vterm_show = 0 | endif 
    au VimLeave     * VTermClose
    "autocmd BufDelete * if &buftype == "terminal" | unlet t:vterm_bufname | endif 
augroup end

if has('nvim')
    augroup VTERM_NVIM
        au TermClose    * call VTermClose()
    augroup end
else
    augroup VTERM_VIM 
        au BufWipeout * if &filetype == "vterm" | unlet t:vterm_bufname | endif
    augroup end
endif

exe 'tnoremap ' . vterm_map_toggleterm . ' <C-\><C-n>:call VTermToggleTerminal()<CR>'
exe 'nnoremap ' . vterm_map_toggleterm . ' :call VTermToggleTerminal()<CR>'
exe 'tnoremap ' . vterm_map_togglefocus . ' <C-\><C-n>:call VTermToggleFocus()<CR>'
exe 'nnoremap ' . vterm_map_togglefocus . ' :call VTermToggleFocus()<CR>'

command! -n=0 -bar VTermToggleTerminal call VTermToggleTerminal()
command! -n=0 -bar VTermToggleFocus call VTermToggleFocus() 
command! -n=0 -bar VTermClose call VTermClose() 
