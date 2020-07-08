" inclusion guard
if exists('g:loaded_notez')
    finish
endif
let g:loaded_notez = 1

command! -nargs=0 NotezHelloWorld call notez#Hello()
command! -nargs=0 OND call notez#OpenJournal()  " TODO: better way?
command! -nargs=0 OpenNotezJournal call notez#OpenJournal()
