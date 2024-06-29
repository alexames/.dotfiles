""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   Keybinds                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Disable arrow keys in all cases. This is done just to help break bad habits.
" If you're using vim, you should get in the habit of using hjkl for movement!
nnoremap <left> <nop>
nnoremap <right> <nop>
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>

" Disable scroll wheel in all cases.
inoremap <ScrollWheelUp> <nop>
inoremap <S-ScrollWheelUp> <nop>
inoremap <C-ScrollWheelUp> <nop>
inoremap <ScrollWheelDown> <nop>
inoremap <S-ScrollWheelDown> <nop>
inoremap <C-ScrollWheelDown> <nop>
inoremap <ScrollWheelLeft> <nop>
inoremap <S-ScrollWheelLeft> <nop>
inoremap <C-ScrollWheelLeft> <nop>
inoremap <ScrollWheelRight> <nop>
inoremap <S-ScrollWheelRight> <nop>
inoremap <C-ScrollWheelRight> <nop>
nnoremap <ScrollWheelUp> <nop>
nnoremap <S-ScrollWheelUp> <nop>
nnoremap <C-ScrollWheelUp> <nop>
nnoremap <ScrollWheelDown> <nop>
nnoremap <S-ScrollWheelDown> <nop>
nnoremap <C-ScrollWheelDown> <nop>
nnoremap <ScrollWheelLeft> <nop>
nnoremap <S-ScrollWheelLeft> <nop>
nnoremap <C-ScrollWheelLeft> <nop>
nnoremap <ScrollWheelRight> <nop>
nnoremap <S-ScrollWheelRight> <nop>
nnoremap <C-ScrollWheelRight> <nop>

" Up/down should always move as expected, regardless of wrapping.
nnoremap j gj
nnoremap k gk

" By default Y yanks the whole line unlike C and D, which operate from the
" cursor position to the end of the line. Make Y behave like C or D, it should
" yank to the end of the line.
map Y y$

" Cutting and pasting to system clipboard
" Ctrl+C copies highlighted text to clipboard.
" Ctrl+V pastes at the cursor position (or over highlighted text in visual mode)
vmap <C-c> "+y
vmap <C-x> "+d
imap <C-v> <esc>"+pa

" Move between buffer panes with <C-direction>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

tnoremap <C-h> <C-w>h
tnoremap <C-j> <C-w>j
tnoremap <C-k> <C-w>k
tnoremap <C-l> <C-w>l

tnoremap :: <C-W>:

" Use \v to open a tab with ~/.vimrc for fast editing of the .vimrc.
nnoremap <leader>v :tabe! $MYVIMRC<CR>

" Use \cw to open a pane with quickfix window.
" This is where build output and search results go.
nnoremap <leader>cw :botright cwindow<CR>

" Fat-finger fixes - common typos I make that are annoying.
map <S-k> k
nnoremap ! :!
nnoremap q: :q

" Spacebar toggles folds
nnoremap <space> za

" Quick save and loading of sessions
nnoremap <F7> :mksession! ./.vim_session<cr>
nnoremap <F8> :source ./.vim_session<cr>

function! Preserve(command)
    let w = winsaveview()
    execute a:command
    call winrestview(w)
endfunction

vnoremap <C-h> y:call Preserve("%S/<C-r>"//g")<left><left><left><left>
vnoremap <C-f> y:grep <C-r>" %:p:h

" Q should format around paragraph
nnoremap Q gqap

cmap <C-V> <C-R>+

" Display matches of last search in window
nnoremap <silent> <leader>g :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>

nnoremap <silent> <leader><space> :call Preserve("%s/\\s\\+$//e")<CR>

" Replace selected text with text in paste register, without overwriting the
" text in the yank register with the text replaced.
function! RestoreRegister()
    let @" = s:restore_reg
    return ''
endfunction
function! PasteOver()
     let s:restore_reg = @"
     return "p@=RestoreRegister()\<cr>"
endfunction
vnoremap <silent> <expr> p PasteOver()

" Toggle visible whitespace (useful when you want to copy a line without
" picking up the various dots and symbols)
nnoremap <leader>w :set list!<cr>

" Center the screen when jumping to successive search results.
" nnoremap n nzz
" nnoremap N Nzz
" nnoremap * *zz
" nnoremap # #zz
" nnoremap g* g*zz
" nnoremap g# g#zz

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin: godlygeek/tabular

vmap <S-T> :Tab /\|<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin: 'ilyachur/cmake4vim'

nnoremap <C-t> :FZFCMakeSelectTarget<CR>
nnoremap <leader>b :CMakeBuild<CR>
nnoremap <f5> :CMakeRun<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin: scrooloose/nerdtree

nnoremap <f2> :NERDTreeToggle<CR>
nnoremap <f3> :NERDTreeFocus<CR>
nnoremap <f4> :NERDTreeFind<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin: junegunn/fzf.vim

nnoremap <C-p> :Files<cr>
nnoremap <C-a> :Ag<cr>
nnoremap <C-b> :Buffers<cr>
nnoremap <C-g> :History<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin: vim-scripts/tComment

nnoremap g/ :TComment<CR>
vnoremap g/ :TComment<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin 'ycm-core/YouCompleteMe'

nnoremap ti :YcmCompleter GoToInclude<cr>
nnoremap tD :YcmCompleter GoToDeclaration<cr>
nnoremap td :YcmCompleter GoToDefinition<cr>
nnoremap ts :YcmCompleter GoTo<cr>
nnoremap tr :YcmCompleter GoToReferences<cr>

nmap fs <Plug>(YCMFindSymbolInWorkspace)
nmap <C-y> <Plug>(YCMFindSymbolInWorkspace)

nnoremap <leader>r :YcmCompleter RefactorRename

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin 'google/vim-codefmt'

nnoremap <silent> <leader>= :call Preserve("FormatCode")<CR>
vnoremap <silent> <leader>= :call Preserve("FormatLines")<CR>
