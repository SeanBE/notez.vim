if !exists("g:notez_diary_dir")
    let g:notez_diary_dir="~/.notes"
endif

function! notez#Hello()
    echom "Hello, world!"
endfunction

function! notez#OpenDiary()
    let weekn = substitute(system('date +%V'),"\\n","","")
    execute 'cd ' . g:notez_diary_dir
    execute ':edit diary/' . weekn . '.md'
    " TODO: diary dir does not exist? add dynamic template if new file
endfunction
