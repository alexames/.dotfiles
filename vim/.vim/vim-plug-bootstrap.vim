""""""""""""""""""""""""""""""""""""""""
" vim-plug automatic installation
" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
let data_dir = has('nvim') ? stdpath('data') . '/site' : expand('$HOME/.vim')
let autoload_dir = data_dir . '/autoload'
if empty(glob(autoload_dir))
  silent execute '!mkdir ' . autoload_dir
endif

let plug_path = data_dir . '/autoload/plug.vim'
if empty(glob(plug_path))
  let plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  if has('win32')
    silent execute '!Invoke-WebRequest -OutFile ' . plug_path . ' -Uri ' . plug_url
  else
    silent execute '!curl -fLo ' . plug_path . ' --create-dirs ' . plug_url
  endif
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

