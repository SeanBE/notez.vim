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
command! -nargs=0 OpenNotezJournal  call notez#OpenJournal()
command! -nargs=0 OpenNotezTodo     call notez#OpenTodo()

" TODO: open fzf window for full word search
command! -nargs=0 SearchNotes       call notez#SearchNotes()
" TODO: open fzf window with whats under cursor (share with above command?)
"command! -nargs=0 SearchInNotes    call notez#SearchInNotes(<q-args>)
" TODO: open fzf to search for all ctags generated
command! -nargs=0 SearchTags        call notez#SearchTags()
" TODO: fzf window with results
"command! -nargs=0 SearchForTag     call notez#SearchForTag()
" TODO: some command to link other files?

" init mappings
nnoremap <Plug>(Notez-NewNote)                  :NewNotez<Space>
nnoremap <silent> <Plug>(Notez-OpenTodo)        :OpenNotezTodo<CR>
nnoremap <silent> <Plug>(Notez-OpenJournal)     :OpenNotezJournal<CR>
nnoremap <silent> <Plug>(Notez-SearchNotes)     :SearchNotes<CR>

" apply defaults
let g:notez_default_mappings = get(g:, "notez_default_mappings", 1)
if g:notez_default_mappings
    nmap <localleader>nn             <Plug>(Notez-NewNote)
    nmap <silent> <localleader>nt    <Plug>(Notez-OpenTodo)
    nmap <silent> <localleader>nd    <Plug>(Notez-OpenJournal)
    nmap <silent> <localleader>nf    <Plug>(Notez-SearchNotes)
endif
