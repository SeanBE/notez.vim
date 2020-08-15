function! notez#SetupJournal()
    call setline(1, "# Journal for " . expand('%:r') . ' (started on ' . strftime("%Y-%m-%d") . ')')
    exe "normal! o"
endfunction

function! s:setJournalCommands() abort " {{{1
    nnoremap <Plug>(Notez-NextJournal) :call notez#NextJournal()<CR>
    nnoremap <Plug>(Notez-PrevJournal) :call notez#PrevJournal()<CR>
    if g:notez_default_mappings
        nmap <localleader>n] <Plug>(Notez-NextJournal)
        nmap <localleader>n[ <Plug>(Notez-PrevJournal)
    endif
endfunction

function! s:commit_to_git()
    " add all in directory. gitignore only accepts itself + .md
    " based off https://opensource.com/article/18/6/vimwiki-gitlab-notes
    " https://vi.stackexchange.com/questions/3060/suppress-output-from-a-vim-autocomand
    silent! execute '!git -C '.g:notez_dir.' add \*.md; git -C '.g:notez_dir.' diff-index --quiet HEAD || git -C '.g:notez_dir.' commit -q --no-status -m %;'
endfunction

function! s:path_inside_journal_dir()
    " https://stackoverflow.com/questions/12094708/include-a-directory-recursively-for-vim-autocompletion
    return expand('%:p') =~ expand(g:notez_journal_dir)
endfunction

augroup notez#Journal
    autocmd!
    au BufNewFile *.md if s:path_inside_journal_dir() | :call notez#SetupJournal()
    au BufWritePost *.md if s:path_inside_journal_dir() | :call s:commit_to_git()
    au BufNew,BufEnter *.md if s:path_inside_journal_dir() | :call s:setJournalCommands()
augroup end

function! notez#OpenJournal()
    exe 'cd ' . g:notez_journal_dir
    let filename = substitute(system('date +%Ywk%V'),"\\n","","")
    exe ':e ' . filename . '.md'
endfunction

function! notez#OpenTodo()
    exe 'cd ' . g:notez_journal_dir
    exe ':e TODO.md'
endfunction

function! s:parse_journal_filename(fname)
    let l:year=strpart(a:fname, 0, 4)
    let l:week=strpart(a:fname, 6, 2)
    " httpsgg://stackoverflow.com/a/46002400
    let l:start_of_week = substitute(system('date -d "'.year.'-01-01 +$(( '.week.' * 7 + 1 - $(date -d "2020-01-04" +%u ) - 3 )) days - 2 days + 1 days" +"%Y-%m-%d"'), "\\n","","")
    return l:start_of_week
endfunction

function! notez#PrevJournal()
    let l:current = expand('%:t:r')
    let l:start_of_week = s:parse_journal_filename(current)
    let filename = substitute(system('date -d "' . start_of_week . ' - 7 days" +%Ywk%V'),"\\n","","")
    exe ':e ' . filename . '.md'
endfunction

function! notez#NextJournal()
    let l:current = expand('%:t:r')
    let l:start_of_week = s:parse_journal_filename(current)
    let filename = substitute(system('date -d "' . start_of_week . ' + 7 days" +%Ywk%V'),"\\n","","")
    exe ':e ' . filename . '.md'
endfunction

function! notez#NewNote(filename)
    echom a:filename

endfunction

