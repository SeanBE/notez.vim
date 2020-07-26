" inclusion guard
if exists('g:loaded_notez') || &compatible
    finish
endif
let g:loaded_notez = 1

" get notez.dir absolute path
let s:plugin_dir = expand('<sfile>:p:h:h')

" use quoted args for filename arg
command! -nargs=1 NewNote call notez#NewNote(<q-args>)
command! -nargs=0 OpenNotezJournal call notez#OpenJournal()

nnoremap <localleader>nn :NewNote
nnoremap <localleader>od :OpenNotezJournal<CR>
