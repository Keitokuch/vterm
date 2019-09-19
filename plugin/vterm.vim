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


function! VTermToggleTerminal() 
    if exists("t:vterm_name")
        if (t:vterm_show == 0)
            let t:vterm_show = 1
            let t:vterm_last_win = win_getid() 
            bo split
            exe "resize " . t:vterm_height 
            exe "buffer" t:vterm_name
            startinsert!
        else 
            let t:vterm_show = 0 
            let t:vterm_height = winheight(bufwinnr(t:vterm_name))
            if bufwinnr(t:vterm_name) == winnr()
                exe win_id2win(t:vterm_last_win) . "wincmd w"
            endif
            exe bufwinnr(t:vterm_name)"hide"
        endif
    else 
        let t:vterm_show = 1
        let t:vterm_last_win = win_getid()
        bo split
        exe "resize " . t:vterm_height 
        terminal
        let t:vterm_name = bufname("%")
        startinsert!
    endif
endfunction

function! VTermToggleFocus()
    if (exists("t:vterm_name") && t:vterm_show == 1)
        let l:term_win = bufwinnr(t:vterm_name)
        let l:curr_win = winnr()
        if l:term_win == l:curr_win
            exe win_id2win(t:vterm_last_win) . "wincmd w"
        else 
            let t:vterm_last_win = winnr()
            let t:vterm_last_win = win_getid() 
            exe bufwinnr(t:vterm_name) . "wincmd w"
            startinsert!
        endif
    endif
endfunction

function! VTermClose()
    if (exists("t:vterm_name"))
        if (t:vterm_show == 1)
            let t:vterm_show = 0 
            let t:vterm_height = g:vterm_win_height 
            if bufwinnr(t:vterm_name) == winnr() 
                exe win_id2win(t:vterm_last_win) . "wincmd w" 
            endif 
            exe bufwinnr(t:vterm_name)"hide"
        endif 
        exe "bdelete! " . t:vterm_name 
        unlet t:vterm_name 
    endif 
endfunction 

exe 'tnoremap ' . vterm_map_toggleterm . ' <C-\><C-n>:call VTermToggleTerminal()<CR>'
exe 'nnoremap ' . vterm_map_toggleterm . ' :call VTermToggleTerminal()<CR>'
exe 'tnoremap ' . vterm_map_togglefocus . ' <C-\><C-n>:call VTermToggleFocus()<CR>'
exe 'nnoremap ' . vterm_map_togglefocus . ' :call VTermToggleFocus()<CR>'
au TabEnter * let t:vterm_show = 0 | let t:vterm_height = g:vterm_win_height 
au VimEnter * let t:vterm_show = 0 | let t:vterm_height = g:vterm_win_height 
autocmd bufenter * if (winnr("$") == 1 && &buftype ==# 'terminal' ) | q | endif
autocmd BufWinLeave * if &buftype == "terminal" | let t:vterm_show = 0 | endif 
autocmd BufDelete * if &buftype == "terminal" | unlet t:vterm_name | endif 

command! -n=0 -bar VTermClose call VTermToggleTerminal()
command! -n=0 -bar VTermToggleFocus call VTermToggleFocus() 
command! -n=0 -bar VTermClose call VTermClose() 
