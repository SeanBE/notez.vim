# notez.vim

Yet another notes plugin! This is the outcome from me wanting to move away from vimwiki and learn how to buld my own vim plugin.
I have nothing against vimwiki. I highly recommend it to everyone. It's packed with more features than I could ever need. 

This does not come with any markdown goodies so I recommend finding something else to complement this (e.g. plasticboy/vim-markdown).

What does this plugin do?
* Quick mappings to open a weekly journal or create a new note.
* Search tags (and generate), files, and text within your notes dir (powered by fzf)
* Link notes a la Zettelkasten.

This is a work in progress. I've tried to follow some best practices but I'm 100% confident that a lot of this can be rewritten in a more optimal fashion. This includes:
* Using location list to toggle between all my journals.
* Not being a lazy git and completing documentation
* I want to be able to use `ts` for tags as well but I need to figure out an alternative to the fzf issue first.
* List goes on.

Would love to hear your feedback, comments, criticism etc. so that the plugin and I can improve :) 

### Installation
This has been tested on Vim 8.2. It requires the `ctags`, `FZF` binary, `FZF` vim plugin, `ripgrep`, and `bat`.
The plugin has been built to be pathogen compatible. This means you can install it using vim 8+ builtin package manager or one of the several 3rd party plugin managers out there.

```vim
" using vim-plug
call plug#begin()
Plug 'seanbe/notez.vim'
call plug#end()

" To disable the plugin mappings
let g:notez_nomap = 1

" <localleader>nn to create a note
" <localleader>nd to open your weekly journal
" Check out the docs for more.
```
