# vterm
This plugin creates and manages a terminal window at the bottom of vim, providing keyboard mappings for window toggling and focusing.

### Installation
Install plugin using package managers like [vim-plug](https://github.com/junegunn/vim-plug). Add
```
Plug 'keitokuch/vterm'
```

### Usage
In normal mode,

`Ctrl-T` Toggles terminal window on and off

`Ctrl-Q` Switches focus between terminal window and editing window

Inside VTerm window,

Press `<ESC>` or `;;` to exit to normal mode

Press `i` to enter terminal mode

Press `a` in normal mode to toggle zooming fullscreen

Press `;a` in terminal mode to toggle zooming fullscreen


### Custom mappings
VTerm key usages can be customized. To change the default mapping, add and change the followings in your `init.vim` or `.vimrc`
``` vim
let g:vterm_map_toggleterm = '<C-t>'
let g:vterm_map_togglefocus = '<C-q>'
let g:vterm_map_zoomnormal = 'a'
let g:vterm_map_zoomterm = ';a'
let g:vterm_map_escape = ';;'
```
