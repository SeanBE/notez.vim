
function! notez#SetupJournal() abort " {{{1
    let l:note_path = expand('%:r')
    let l:top_line = printf("# Journal for %s (created at %s)", l:note_path, strftime(s:date_fmt))
    call setline(1, l:top_line)
    exe "normal! o"
endfunction

function! s:setJournalCommands() abort " {{{1
    nnoremap <Plug>(Notez-NextJournal) :call notez#NextJournal()<CR>
    nnoremap <Plug>(Notez-PrevJournal) :call notez#PrevJournal()<CR>
    if g:notez_nomap
        nmap <localleader>n] <Plug>(Notez-NextJournal)
        nmap <localleader>n[ <Plug>(Notez-PrevJournal)
    endif
endfunction

function! s:commit_to_git() abort " {{{1
    " add all in directory. gitignore only accepts itself + .md
    " based off https://opensource.com/article/18/6/vimwiki-gitlab-notes
    let l:git_cmd = '!git -C '.g:notez_dir
    silent! execute l:git_cmd.' add \*.md; ' 
                \ l:git_cmd.' diff-index --quiet HEAD || '
                \ l:git_cmd.' commit -q --no-status -m %;'
endfunction

function! s:path_inside(dir) abort " {{{1
    return expand('%:p') =~ expand(a:dir)
endfunction

augroup notez#Journal " {{{1
    autocmd!
    au BufWritePost *.md if s:path_inside(g:notez_dir) | :call s:commit_to_git()
    au BufNewFile *.md if s:path_inside(g:notez_journal_dir) | :call notez#SetupJournal()
    au BufNew,BufEnter *.md if s:path_inside(g:notez_journal_dir) | :call s:setJournalCommands()
augroup end

function! notez#OpenJournal() abort " {{{1
    exe 'cd ' . g:notez_journal_dir
    let l:filename = printf("%s.md", substitute(system('date +%Ywk%V'),"\\n","",""))
    exe 'edit '.l:filename
endfunction
 
function! notez#OpenTodo() abort " {{{1
    exe 'cd ' . g:notez_journal_dir
    exe 'edit TODO.md'
endfunction

function! s:parse_journal_filename(fname) abort " {{{1
    let l:year=strpart(a:fname, 0, 4)
    let l:week=strpart(a:fname, 6, 2)
    " httpsgg://stackoverflow.com/a/46002400
    let l:start_of_week = substitute(system('date -d "'.year.'-01-01 +$(( '.week.' * 7 + 1 - $(date -d "2020-01-04" +%u ) - 3 )) days - 2 days + 1 days" +"%Y-%m-%d"'), "\\n","","")
    return l:start_of_week
endfunction

function! notez#PrevJournal() abort " {{{1
    let l:current = expand('%:t:r')
    let l:start_of_week = s:parse_journal_filename(current)
    let filename = substitute(system('date -d "' . start_of_week . ' - 7 days" +%Ywk%V'),"\\n","","")
    exe 'edit '.printf("%s.md", filename)
endfunction

function! notez#NextJournal() abort " {{{1
    let l:current = expand('%:t:r')
    let l:start_of_week = s:parse_journal_filename(current)
    let filename = substitute(system('date -d "' . start_of_week . ' + 7 days" +%Ywk%V'),"\\n","","")
    exe 'edit '.printf("%s.md", filename)
endfunction

function! notez#NewNote(filename) abort " {{{1
    exe 'cd ' . g:notez_dir
    let l:filename_with_ts = printf("%s-%s.md", 
                \ substitute(a:filename, " ", "_", ""), 
                \ strftime("%Y-%m-%d-%H%M"))
    exe "edit ".filename_with_ts
endfunction


endfunction

