
function! notez#SetupJournal()
    call setline(1, "# Journal for " . expand('%:r') . ' (started on ' . strftime("%Y-%m-%d") . ')')
    exe "normal! o"
endfunction

augroup notez#Journal
    au BufNewFile *.md if expand('%:p') =~ expand(g:notez_journal_dir) | :call notez#SetupJournal()
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
