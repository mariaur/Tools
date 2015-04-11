" COMMON SETTINGS
set shiftwidth      =4
set tabstop         =4
set expandtab
set cino            =g0,(shiftwidth
set hid
set nobackup
set ic
set nohls
set nowrap


" KEYBOARD MAPPINGS

" errors navigation
map <F8>            :cn<CR>
map <S-F8>          :cp<CR>


" indent
inoremap <S-Tab>    <C-O><LT><LT>
vnoremap <Tab>      >
vnoremap <S-Tab>    <LT>

" bookmarks
nmap <C-F2>         mM
nmap <F2>           'M
imap <C-F2>         <C-O>mM
imap <F2>           <C-O>'M

" document navigation
nmap <C-Tab>        :bnext<CR>
nmap <S-C-Tab>      :bprevious<CR>
imap <C-Tab>        <C-O>:bnext<CR>
imap <S-C-Tab>      <C-O>:bprevious<CR>

" find
nmap <C-f>           /
imap <C-f>           <C-O>/

nmap <C-D>           :bw<CR>
imap <C-D>           <C-O>:bw<CR>

map <C-Right>       w
map <C-Left>        b
vmap <S-C-Right>    w
vmap <S-C-Left>     b
nmap <S-C-Right>    vw<C-G>
nmap <S-C-Left>     vb<C-G>
imap <S-C-Right>    <C-O><S-C-Right>
imap <S-C-Left>     <C-O><S-C-Left>


" GUI Settings
set guifont             =Courier_New:h10
hi Comment              gui=NONE guifg=SeaGreen
hi Statement            gui=NONE guifg=#0000ff
hi PreProc              gui=NONE guifg=#0000ff
hi Type                 gui=bold guifg=#0000ff

hi link StorageClass    Statement
hi link Structure       Statement


" Start VIM maximized
autocmd GUIEnter * simalt ~x

set virtualedit         =all

set suffixes            +=.cpp
set suffixes            +=.cs
set suffixes            +=.xml
set suffixes            +=.xsd

set suffixes            -=.bak
set suffixes            -=.swp
set suffixes            -=.obj
set suffixes            -=.info
set suffixes            -=.o
set autowrite

hi SourceFiles          gui=NONE guifg=#ff0000
let g:explSuffixesLast  =-1

" vim -b : edit binary using xxd-format!
augroup Binary
  au!
  au BufReadPre  *.bin,*.exe,*.obj,*.dll,*.lib            let &bin=1
  au BufReadPost *.bin,*.exe,*.obj,*.dll,*.lib            if &bin | %!xxd -g1
  au BufReadPost *.bin,*.exe,*.obj,*.dll,*.lib            set ft=xxd | endif
  au BufWritePre *.bin,*.exe,*.obj,*.dll,*.lib            if &bin | %!xxd -r
  au BufWritePre *.bin,*.exe,*.obj,*.dll,*.lib            endif
  au BufWritePost *.bin,*.exe,*.obj,*.dll,*.lib           if &bin | %!xxd
  au BufWritePost *.bin,*.exe,*.obj,*.dll,*.lib           set nomod | endif
augroup END

" sources/dirs filetype rule
au! BufRead,BufNewFile [Ss]ources*     set filetype=make
au! BufRead,BufNewFile [Mm]akefile*     set filetype=make
au! BufRead,BufNewFile dirs             set filetype=make
au! BufRead,BufNewFile *.inc            set filetype=make
au! BufRead,BufNewFile *.wx[is]         set filetype=xml
au! BufRead,BufNewFile *.*proj          set filetype=xml
au! BufRead,BufNewFile *.targets        set filetype=xml
au! BufRead,BufNewFile *.props          set filetype=xml
au! BufRead,BufNewFile *.man            set filetype=xml

" set indent spaces to 2
au FileType xml setlocal shiftwidth=2


" component manifest files or MAN files
au BufNewFile,BufRead *.man
 	\ if getline(1) =~ '<?\s*xml.*?>' |
 	\   setf xml |
    \ else       |
    \   setf man |
 	\ endif


" abbreviations
iabbrev nib PRIVATE: NIB:

