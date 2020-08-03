
function! notez#SetupJournal()
    let lastweekn = substitute(system('date -d "last week" +%V'),"\\n","","")
    let nextweekn = substitute(system('date -d "next week" +%V'),"\\n","","")
    call setline(1, "# Journal for Week #" . expand('%:r') . ' (started on ' . strftime("%Y-%M-%d") . ')')
    call setline(2, "<!-- [" . lastweekn . ".md] - [" . nextweekn . ".md] -->")
    call setline(3, "* ")
    exe "normal! G"
    startinsert!
endfunction

augroup notez#Journal
    " TODO: can we move the autocmd-pattern higher to reduce repeat.
    "au BufNewFile *.md if expand('%:p') =~ expand(g:notez_journal_dir) | 0r <sfile>:p:h:h/templates/journal.md
    au BufNewFile *.md if expand('%:p') =~ expand(g:notez_journal_dir) | :call notez#SetupJournal()
    " https://stackoverflow.com/questions/12094708/include-a-directory-recursively-for-vim-autocompletion
    "au VimEnter *.md if expand('%:p') =~ expand(g:notez_journal_dir) | set complete=k/journal/*
augroup end

function! notez#OpenJournal()
    let weekn = substitute(system('date +%V'),"\\n","","")
    exe 'cd ' . g:notez_journal_dir
    exe ':e ' . weekn . '.md'
endfunction
