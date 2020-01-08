# vterm
A neovim plugin for a better built-in terminal experience.

### Usage
`Ctrl-T` Toggles terminal window on and off

`Ctrl-Q` Switches focus between terminal window and editing window


### Custom mapping
To change the default usages, map the followings in `init.vim`
``` conf
let g:vterm_map_toggleterm = '<C-t>'
let g:vterm_map_togglefocus = '<C-q>'
```
