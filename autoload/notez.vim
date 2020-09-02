let s:date_fmt = "%Y-%m-%d-%H%M"

function! s:get_visual_selection() abort " {{{1
  " source: https://stackoverflow.com/a/6271254/2467963
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
endfunction

function! notez#SetupJournal() abort " {{{1
    let l:note_path = expand('%:t:r')
    let l:top_line = printf("# Journal for %s (created at %s)", l:note_path, strftime(s:date_fmt))
    call setline(1, l:top_line)
    exe "normal! o"
endfunction

function! s:setJournalCommands() abort " {{{1
    nnoremap <Plug>(Notez-NextJournal) :call notez#NextJournal()<CR>
    nnoremap <Plug>(Notez-PrevJournal) :call notez#PrevJournal()<CR>
    if g:notez_nomap
        nmap <buffer> <localleader>n] <Plug>(Notez-NextJournal)
        nmap <buffer> <localleader>n[ <Plug>(Notez-PrevJournal)
    endif
endfunction

function! s:commit_to_git() abort " {{{1
    " add all in directory. gitignore only accepts itself + .md
    " based off https://opensource.com/article/18/6/vimwiki-gitlab-notes
    let l:git_cmd = 'git -C '.g:notez_dir
    silent! execute '!'.l:git_cmd.' add \*.md; '
                \ l:git_cmd.' diff-index --quiet HEAD || '
                \ l:git_cmd.' commit -q --no-status -m %;'
endfunction

function! s:run_ctags() abort " {{{1
    let l:ctags_cmd = join([
                \ 'ctags -a --recurse',
                \ '--langdef=notezmd',
                \ '--languages=notezmd',
                \ '--langmap=notezmd:.md',
                \ '--mline-regex-notezmd="/(^|[[:space:]])@(\w\S*)/\2/t/{mgroup=1}"'
                \])
    silent let ctags_out = system(ctags_cmd)
endfunction

function! s:setupNotez() abort " {{{1
    " setlocal spell
endfunction

function! s:path_inside(dir) abort " {{{1
    return expand('%:p') =~ expand(a:dir)
endfunction

augroup notez#Journal " {{{1
    autocmd!
    au BufWritePost *.md if s:path_inside(g:notez_dir) | :call s:run_ctags() | endif
    au BufWritePost *.md if s:path_inside(g:notez_dir) | :call s:commit_to_git() | endif
    au BufNew,BufEnter *.md if s:path_inside(g:notez_dir) | :call s:setupNotez() | endif
    au BufNewFile *.md if s:path_inside(g:notez_journal_dir) | :call notez#SetupJournal() | endif
    au BufNew,BufEnter *.md if s:path_inside(g:notez_journal_dir) | :call s:setJournalCommands() | endif
augroup end

function! notez#OpenJournal() abort " {{{1
    exe 'cd ' . g:notez_dir
    let l:filename = printf("%s.md", substitute(system('date +%Ywk%V'),"\\n","",""))
    exe 'edit 'g:notez_journal_dir.'/'.l:filename
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
    exe 'edit '.printf("%s/%s.md", g:notez_journal_dir, filename)
endfunction

function! notez#NextJournal() abort " {{{1
    let l:current = expand('%:t:r')
    let l:start_of_week = s:parse_journal_filename(current)
    let filename = substitute(system('date -d "' . start_of_week . ' + 7 days" +%Ywk%V'),"\\n","","")
    exe 'edit '.printf("%s/%s.md", g:notez_journal_dir, filename)
endfunction

function! notez#NewNote(filename) abort " {{{1
    exe 'cd ' . g:notez_dir
    let l:filename_with_ts = printf("%s-%s.md",
                \ substitute(a:filename, " ", "_", ""),
                \ strftime("%Y-%m-%d-%H%M"))
    exe "edit ".filename_with_ts
endfunction

" {{{1

function notez#SearchFiles() abort
    " wrapping it takes any fzf configuration the user may have.
    call fzf#run(fzf#wrap({
                \ 'source': 'rg --files -t md', 
                \ 'dir': g:notez_dir, 
                \ 'sink': 'e', 
                \ 'options': '--reverse --preview'
                \ }))
endfunction

function! notez#SearchNotes() abort
    " TODO: Search for whole word
    call fzf#run(fzf#wrap(fzf#vim#with_preview({
                \ 'source': 'rg --files -t md', 
                \ 'dir': g:notez_dir, 
                \ 'sink': 'e', 
                \ 'down': '35%'
                \ })))
endfunction

function! notez#SearchTags() abort
" TODO: Search tags
endfunction

function! notez#SearchTODOs() abort
" TODO: search for TODOs
endfunction
