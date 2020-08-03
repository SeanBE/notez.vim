
function! notez#SetupJournal()
    call setline(1, "# Journal for " . expand('%:r') . ' (started on ' . strftime("%Y-%m-%d") . ')')
    call setline(2, "* ")
    exe "normal! G"
    startinsert!
endfunction

augroup notez#Journal
    au BufNewFile *.md if expand('%:p') =~ expand(g:notez_journal_dir) | :call notez#SetupJournal()
augroup end

function! notez#OpenJournal()
    let iso_date = substitute(system('date -I'),"\\n","","")
    let filename = substitute(system('date -d "' . iso_date . '" +%Ywk%V'),"\\n","","")
    exe 'cd ' . g:notez_journal_dir
    exe ':e ' . filename . '.md'
endfunction
