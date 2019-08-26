if !has('nvim')
    finish
endif

if exists('g:loaded_vterm')
    finish 
endif

let g:loaded_vterm = 1

function! VTermToggleTerminal() 
    if exists("t:vterm_name")
        if (t:term_show == 0)
            let t:vterm_show = 1
            below split 
            resize 8 
            exe "buffer" t:vterm_name
        else 
            wincmd j
        endif
    else 
        let t:vterm_show = 1
        below split 
        resize 8
        terminal
        let t:vterm_name = bufname("%")
    endif
endfunction

tnoremap jj <C-\><C-n>
nnoremap <expr> <C-q> exists("t:vterm_name") && t:vterm_show ==1 ? "wincmd j" : ""
tnoremap <C-q> <C-\><C-n>:hide<CR>
nnoremap <C-t> :call VTermToggleTerminal()<CR>i
tnoremap <C-t> <C-\><C-n><C-w>k
au TabEnter * let t:vterm_show = 0 
au VimEnter * let t:vterm_show = 0 
autocmd bufenter * if (winnr("$") == 1 && &buftype ==# 'terminal' ) | q | endif
autocmd bufenter * if (winnr("$") == 2 && &buftype ==# 'terminal' && bufwinnr("NERD_tree_1") == 1) | q | endif
autocmd BufWinLeave * if &buftype == "terminal" | let t:vterm_show = 0 | endif 
autocmd BufDelete * if &buftype == "terminal" | unlet t:vterm_name | endif 

