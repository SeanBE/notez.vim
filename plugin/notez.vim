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

if !exists('*fzf#run') || !executable('rg')
    echoerr '`fzf` and `rg` must be installed.'
    finish
endif

" get notez.dir absolute path
let s:plugin_dir = expand('<sfile>:p:h:h')

" init global cmds
command! -nargs=1 NewNotez          call notez#NewNote(<q-args>)

" init mappings
nnoremap <Plug>(Notez-NewNote)                  :NewNotez<Space>
inoremap <expr> <Plug>(Notez-LinkNote)          notez#LinkNote()
nnoremap <silent> <Plug>(Notez-SearchTags)      :call notez#SearchTags()<CR>
nnoremap <silent> <Plug>(Notez-SearchFiles)     :call notez#SearchFiles()<CR>
nnoremap <silent> <Plug>(Notez-SearchNotes)     :call notez#SearchNotes()<CR>
nnoremap <silent> <Plug>(Notez-OpenJournal)     :call notez#OpenJournal()<CR>


" apply defaults
let g:notez_nomap = get(g:, "notez_nomap", 1)
if g:notez_nomap
    " TODO: maybe only map this when in notes dir? or a better mapping key
    imap <c-b>                       <Plug>(Notez-LinkNote)
    nmap <localleader>nn             <Plug>(Notez-NewNote)
    nmap <silent> <localleader>nd    <Plug>(Notez-OpenJournal)
    nmap <silent> <localleader>nt    <Plug>(Notez-SearchFiles)
    nmap <silent> <localleader>nf    <Plug>(Notez-SearchNotes)
    nmap <silent> <localleader>nr    <Plug>(Notez-SearchTags)
endif
