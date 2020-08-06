" inclusion guard
if exists('g:loaded_notez') || &compatible
    finish
endif
let g:loaded_notez = 1

if !exists("g:notez_dir")
    let g:notez_dir="~/.notes"
endif

if !exists("g:notez_journal_dir")
    let g:notez_journal_dir= g:notez_dir . "/journal"
endif

if !isdirectory(expand(g:notez_dir)) || !isdirectory(expand(g:notez_journal_dir))
    echomsg "Notez:vim: Directories ".g:notez_dir." or ".g:notez_journal_dir." do not exist. Make sure they exist first!"
    finish
endif

" get notez.dir absolute path
let s:plugin_dir = expand('<sfile>:p:h:h')

" use quoted args for filename arg
command! -nargs=1 NewNote call notez#NewNote(<q-args>)
command! -nargs=0 OpenNotezJournal call notez#OpenJournal()

nnoremap <localleader>nn :NewNote
nnoremap <localleader>od :OpenNotezJournal<CR>
