# vterm
A neovim plugin for a better built-in terminal experience.

### Installation
Package install using [vim-plug](https://github.com/junegunn/vim-plug) recommended. Add
```
call plug#begin()
Plug 'keitokuch/vterm'
call plug#end()
```

### Usage
`Ctrl-T` Toggles terminal window on and off

`Ctrl-Q` Switches focus between terminal window and editing window

Inside VTerm window,

Press `<ESC>` or `;;` to exit to normal mode

Press `i` to enter terminal mode

Press `a` in normal mode to toggle zooming fullscreen

Press `;a` in terminal mode to toggle zooming fullscreen


### Custom mapping
VTerm key usages can be customized. To change the default mapping, add and change the followings in your `init.vim` or `.vimrc`
``` vim
let g:vterm_map_toggleterm = '<C-t>'
let g:vterm_map_togglefocus = '<C-q>'
let g:vterm_map_zoomnormal = 'a'
let g:vterm_map_zoomterm = ';a'
let g:vterm_map_escape = ';;'
```
