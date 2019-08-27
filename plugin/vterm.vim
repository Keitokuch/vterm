if !has('nvim')
    finish
endif

if exists('g:loaded_vterm')
    finish 
endif

let g:loaded_vterm = 1

function! VTermToggleTerminal() 
    if exists("t:vterm_name")
        if (t:vterm_show == 0)
            let t:vterm_show = 1
            let t:vterm_last_win = winnr() 
            bo split 
            resize 8 
            exe "buffer" t:vterm_name
            startinsert!
        else 
            let t:vterm_show = 0 
            if bufwinnr(t:vterm_name) == winnr()
                exe t:vterm_last_win . "wincmd w"
            endif
            exe bufwinnr(t:vterm_name)"hide"
        endif
    else 
        let t:vterm_show = 1
        let t:vterm_last_win = winnr()
        bo split 
        resize 8
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
            exe t:vterm_last_win . "wincmd w"
        else 
            let t:vterm_last_win = winnr()
            exe bufwinnr(t:vterm_name) . "wincmd w"
            startinsert!
        endif
    endif
endfunction

tnoremap jj <C-\><C-n>
tnoremap <C-t> <C-\><C-n>:call VTermToggleTerminal()<CR>
nnoremap <C-t> :call VTermToggleTerminal()<CR>
nnoremap <C-q> :call VTermToggleFocus()<CR>
tnoremap <C-q> <C-\><C-n>:call VTermToggleFocus()<CR>
au TabEnter * let t:vterm_show = 0 
au VimEnter * let t:vterm_show = 0 
autocmd bufenter * if (winnr("$") == 1 && &buftype ==# 'terminal' ) | q | endif
autocmd bufenter * if (winnr("$") == 2 && &buftype ==# 'terminal' && bufwinnr("NERD_tree_1") == 1) | q | endif
autocmd BufWinLeave * if &buftype == "terminal" | let t:vterm_show = 0 | endif 
autocmd BufDelete * if &buftype == "terminal" | unlet t:vterm_name | endif 

