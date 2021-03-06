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
    " TODO: should be set at plugin level..
    nnoremap <Plug>(Notez-NextJournal) :call notez#NextJournal()<CR>
    nnoremap <Plug>(Notez-PrevJournal) :call notez#PrevJournal()<CR>
    if g:notez_nomap == 0
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
    " TODO: is this the right way ? how long before this slows down?
    " TODO: what happens if we exit mid process?
    let l:curr_dir = getcwd()
    execute "lcd ".expand(g:notez_dir)
    let l:ctags_cmd = join([
                \ 'ctags --recurse',
                \ '--langdef=notezmd',
                \ '--languages=notezmd',
                \ '--langmap=notezmd:.md',
                \ '--mline-regex-notezmd="/(^|[[:space:]])@(\w\S*)/\2/t/{mgroup=1}"'
                \])
    call system(l:ctags_cmd)
    execute "lcd ".l:curr_dir
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

function! s:get_year_week_fmt(...) abort " {{{1
    " convert now or first arg to %year%wk%ISO week number%
    " e.g. get_year_week_fmt('2021-01-04') returns '2021wk04'
    let l:date = get(a:, 1, 0)
    let l:yearWeek = system('date +%Gwk%V')
    if l:date
        let l:yearWeek = system('date -d "'.l:date.'" +%Gwk%V')
    endif
    return substitute(l:yearWeek,"\\n","","")
endfunction

function! notez#OpenJournal() abort " {{{1
    let l:year_week = s:get_year_week_fmt()
    let l:filename = printf("%s.md", l:year_week)
    exe 'edit 'g:notez_journal_dir.'/'.l:filename
endfunction

function! s:parse_journal_filename(fname) abort " {{{1
    " Given file_name, extract iso week number and year
    " Calculate calendar date from week and year
    " https://stackoverflow.com/a/46002400
    " https://en.wikipedia.org/wiki/ISO_week_date#Calculating_an_ordinal_or_month_date_from_a_week_date
    let l:year=strpart(a:fname, 0, 4)
    let l:week=strpart(a:fname, 6, 2)
    let l:start_of_week = system('date -d "'.year.'-01-01 +$(( '.week.' * 7 + 1 - $(date -d ""'.year.'"-01-04" +%u ) - 3 )) days - 2 days + 1 days" +"%Y-%m-%d"')
    return substitute(l:start_of_week, "\\n","","")
endfunction

function! notez#PrevJournal() abort " {{{1
    let l:current = expand('%:t:r')
    let l:start_of_week = s:parse_journal_filename(current)
    let l:year_week = s:get_year_week_fmt(l:start_of_week.' - 7 days')
    exe 'edit '.printf("%s/%s.md", g:notez_journal_dir, l:year_week)
endfunction

function! notez#NextJournal() abort " {{{1
    let l:current = expand('%:t:r')
    let l:start_of_week = s:parse_journal_filename(current)
    let l:year_week = s:get_year_week_fmt(l:start_of_week.' + 7 days')
    exe 'edit '.printf("%s/%s.md", g:notez_journal_dir, l:year_week)
endfunction

function! notez#NewNote(filename) abort " {{{1
    let l:filename_with_ts = printf("%s/%s-%s.md",
                \ g:notez_dir,
                \ substitute(a:filename, " ", "_", "g"),
                \ strftime("%Y-%m-%d-%H%M"))
    exe "edit ".filename_with_ts
endfunction

function notez#SearchFiles() abort " {{{1
    " wrapping it takes any fzf configuration the user may have.
    " initial objective was to lcd to g:notez_dir via autocmd or sink
    " function...this isn't possible because of the following
    " https://github.com/junegunn/fzf/blob/master/plugin/fzf.vim#L502
    call fzf#run(fzf#wrap(fzf#vim#with_preview({
                \ 'sink': 'e',
                \ 'down': '35%',
                \ 'dir': g:notez_dir,
                \ 'options': '--reverse',
                \ 'source': 'rg --files -t md',
                \ })))
endfunction

function! notez#SearchTags() abort " {{{1
    " hack to avoid copying common sink
    let [tags, &tags] = [&tags, expand(g:notez_dir.'/tags')]
    call fzf#vim#tags('', {
  \     'down': '40%',
  \     'options': '--reverse 
  \                 --prompt "> "
  \                 --with-nth 1
  \                 --preview-window="80%"
  \                 --preview "bat --color=always --style=header,plain,numbers '.g:notez_dir.'/{2}"'
  \ })
    let [&tags] = [tags]
endfunction

function! notez#SearchNotes() abort " {{{1
    " Search notes by full word literals using ripgrep.
    " Using lcd for easiest solution (I think) to hiding the abs path of notes
    " https://github.com/junegunn/fzf.vim#example-advanced-ripgrep-integration
    let l:curr_dir = getcwd()
    execute "lcd ".expand(g:notez_dir)
    let command_fmt = 'rg -t md -w --line-number --no-heading --color=always --smart-case %s|| true'
    let initial_command = printf(command_fmt, "\" \"")
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'dir': g:notez_dir, 'options': ['--exact', '--phony', '--query', "", '--bind', 'change:reload:'.reload_command]}
    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec))
    execute "lcd ".l:curr_dir
endfunction

function! s:make_note_link(lines) abort " {{{1
    " fzf#vim#complete returns a list with all info in index 0
    let line = split(a:lines[0], ':')
    let path = l:line[0]
    " remove hashtag from markdown header
    let title = substitute(l:line[1], '\#\s\+', '', 'g')
    return "[" . title ."](". path .")"
endfunction

function! notez#LinkNote() abort " {{{1
    " Search for markdown files that have lines starting with #
    " Using fzf#complete for fuzzy completion (delegates to fzf#vim#complete)
    " From comments https://www.edwinwenink.xyz/posts/48-vim_fast_creating_and_linking_notes/
    " Uses first match of each candidate in completion window.
    " TODO: use journal_dir variable to filter out
    " TODO: push all top level markdown headers in files (drop -m1)
    " TODO: append page number to link syntax
    return fzf#complete({
        \ 'dir': g:notez_dir,
        \ 'source':  'rg -m1 -t md -g "!journal/*" --no-heading --smart-case "^\#" --color always',
        \ 'reducer': function('s:make_note_link'),
        \ 'options': '--exact --ansi --reverse',
        \ 'down': '30%'
        \ })
endfunction
