
function! notez#SetupJournal()
    call setline(1, "# Journal for " . expand('%:r') . ' (started on ' . strftime("%Y-%m-%d") . ')')
    exe "normal! o"
endfunction

function! s:setJournalCommands()
    command! -nargs=0 NextNotezJournal call notez#NextJournal()
    command! -nargs=0 PrevNotezJournal call notez#PrevJournal()
    
    nnoremap <localleader>pj :PrevNotezJournal<CR>
    nnoremap <localleader>nj :NextNotezJournal<CR>
endfunction

function! s:commit_to_git()
    silent! execute '!git -C '.g:notez_dir.' add \*.md; git -C '.g:notez_dir.' diff-index --quiet HEAD || git -C '.g:notez_dir.' commit -q --no-status -m %;'
endfunction

function! s:path_inside_journal_dir()
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
