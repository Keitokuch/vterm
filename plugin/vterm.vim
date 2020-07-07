if exists('g:loaded_vterm')
    finish 
endif

let g:loaded_vterm = 1

let g:vterm_map_toggleterm = get(g:, 'vterm_map_toggleterm', '<C-t>')
let g:vterm_map_togglefocus = get(g:, 'vterm_map_togglefocus', '<C-q>')
let g:vterm_map_zoomnormal = get(g:, 'vterm_map_zoomnormal', 'a')
let g:vterm_map_zoomterm = get(g:, 'vterm_map_zoomterm', ';a')
let g:vterm_map_escape = get(g:, 'vterm_map_escape', ';;')
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
    let t:vterm_winid = win_getid()
    " Create or Load buffer
    if VTermExists()
        " Buffer exists
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
    if VTermExists()
        if t:vterm_show
            let t:vterm_win_height = winheight(bufwinnr(t:vterm_bufname))
        endif
        if s:is_vterm_win()
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
    if (VTermExists() && t:vterm_show == 1)
        if s:is_vterm_win()
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
    if VTermExists()
        if t:vterm_show
            call VTermHideWindow()
            let t:vterm_win_height = g:vterm_win_height 
        endif 
    endif 
endfunction

function! VTermDestroy()
    if VTermExists()
        if bufexists(t:vterm_bufname) 
            exe "bd! " . bufnr(t:vterm_bufname)
        endif
        unlet t:vterm_bufname
    endif
endfu

function! VTermToggleZoom()
    if s:is_vterm_win()
        if get(t:, 'vterm_zoomed', 0) == 0
            let t:vterm_original_height = winheight(bufwinnr(t:vterm_bufname))
            let t:vterm_zoomed = 1
            resize
        else
            let t:vterm_zoomed = 0
            exe 'resize' . t:vterm_original_height
        endif
    endif
endfunction

fu! s:is_vterm_win()
    if bufwinnr(t:vterm_bufname) == winnr()
        return 1
    else
        return 0
    endif
endfu

fu! VTermExists()
    return exists("t:vterm_bufname")
endfu

augroup VTERM
    au FileType vterm set nobuflisted
    au TabEnter     * let t:vterm_win_height = g:vterm_win_height
    au VimEnter     * let t:vterm_win_height = g:vterm_win_height
    au BufEnter     * if (winnr("$") == 1 && &buftype ==# 'terminal' ) | q! | endif
    au BufWinLeave  * if &filetype == "vterm" | let t:vterm_show = 0 | endif 
    au VimLeave     * VTermClose
    au FileType vterm exe 'nmap <buffer> <silent> ' . vterm_map_zoomnormal . ' :VTermToggleZoom<CR>'
    au FileType vterm exe 'tnoremap <buffer> <silent> ' . vterm_map_zoomterm . ' <C-\><C-n>:VTermToggleZoom<CR>:' . s:term_insert . '<CR>'
    au BufHidden    * if &filetype == "vterm" | exe 'buffer' t:vterm_bufname | endif
    au BufEnter     * if VTermExists() | if &ft != "vterm" && win_getid() == t:vterm_winid |
                \  call VTermClose() | endif | endif
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

tnoremap <Esc>  <C-\><C-n>
exe 'tnoremap ' . vterm_map_toggleterm . ' <C-\><C-n>:VTermToggleTerminal<CR>'
exe 'nnoremap ' . vterm_map_toggleterm . ' :VTermToggleTerminal<CR>'
exe 'tnoremap ' . vterm_map_togglefocus . ' <C-\><C-n>:VTermToggleFocus<CR>'
exe 'nnoremap ' . vterm_map_togglefocus . ' :VTermToggleFocus<CR>'
exe 'tnoremap ' . vterm_map_escape . ' <C-\><C-n>'

command! -n=0 -bar VTermToggleTerminal call VTermToggleTerminal()
command! -n=0 -bar VTermToggleFocus call VTermToggleFocus() 
command! -n=0 -bar VTermToggleZoom call VTermToggleZoom() 
command! -n=0 -bar VTermClose call VTermClose() 
command! -n=0 -bar VTermDestroy call VTermDestroy() 
