" dein.vimと使った典型的な初期化処理 {{{
" 古臭いvi互換機能を無効化する
if ! &compatible | set nocompatible | endif
" nvim スペシャル設定
if has('nvim') | let $NVIM_TUI_ENABLE_TRUE_COLOR=1 | endif
 " Reset autocmd
augroup MyAutoCmd
  autocmd!
augroup END
" dein.vim 自体の自動インストール
let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif
let &runtimepath = s:dein_repo_dir .",". &runtimepath
" プラグイン読み込み＆キャッシュ作成
let s:toml_file = fnamemodify(expand('<sfile>'), ':h').'/dein.toml'
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir, [$MYVIMRC, s:toml_file])
  call dein#load_toml(s:toml_file)
  call dein#end()
  call dein#save_state()
endif
" 不足プラグインの自動インストール
if has('vim_starting') && dein#check_install()
  call dein#install()
endif
" }}}

" 以下自分設定、プラグインは dein.toml を弄る {{{

filetype plugin indent on " これをonにしておかないとインデントやプラグインが上手く動かないので必須
syntax on " シンタックスハイライトを有効化
scriptencoding utf-8
" 表示系
set fileformats=unix,dos,mac " 改行コードの自動認識
set ambiwidth=single " ■とか※とかの一部文字を半角として扱うようにする（本音は全角扱いが良いがそれによる不具合も多いのでsingleが無難という結論、iTermの設定とかもambigous widthはシングルにすることにした）
set showmatch " 括弧入力時の対応する括弧を表示
set foldmethod=marker " ファイルを開いた時にマーカーがフォルディングされた状態になるようにする
set nospell " スペルチェックは必要な時に手動で有効化するのでデフォはoffにしておく
set spelllang+=cjk " 日本語はスペルチェック対象から外す
" 装飾系
set number " 行番号を表示
set cursorline " カーソル行の強調表示
set list listchars=tab:▸\ ,trail:-,extends:»,precedes:«,eol:¬,nbsp:% " 非表示文字を見えるようにする
function! s:HilightUnnecessaryWhiteSpace() " 非表示文字をハイライト {{{
  " on ColorScheme
  highlight CopipeMissTab ctermbg=52 guibg=red
  highlight CopipeMissEol ctermbg=52 guibg=red
  highlight TabString ctermbg=52 guibg=red
  highlight ZenkakuSpace ctermbg=52 guibg=red
  " on VimEnter,WinEntercall
  call matchadd("CopipeMissTab", '▸ ')
  call matchadd("CopipeMissEol", '¬ *$')
  " call matchadd("TabString", '\t')
  call matchadd("ZenkakuSpace", '　')
endfunction
autocmd MyAutoCmd ColorScheme,VimEnter,WinEnter * call s:HilightUnnecessaryWhiteSpace() "}}}
" 編集系
set backspace=indent,eol,start " バックスペースで改行やインデントも削除出来るようにする
set autoindent " オートインデントを有効化
autocmd FileType * setlocal formatoptions-=ro "コメント行で改行すると次の行もコメントになってしまうのを防止する
set softtabstop=2 " タブ幅を2タブスペースにする {{{
set shiftwidth=2
set tabstop=2
set expandtab " }}}
" 検索系
set ignorecase " 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set smartcase " 検索文字列に大文字が含まれている場合は区別して検索する
set wrapscan " 検索時に最後まで行ったら最初に戻る
set incsearch " 検索文字列入力時に順次対象文字列にヒットさる
set hlsearch " 検索結果文字列のハイライトを有効にする
set wildmode=list,full " コマンドラインウィンドウのTAB補完で一覧表示が出るようにする
" 操作系
set hidden " 編集のままバッファ切り替えができるようにする
set mouse=a " マウスモード有効
set scrolloff=10 " カーソル位置を画面中央に保つ(画面上下10行より先のカーソル移動は画面の方がスクロールする)
" クリップボードからの貼り付け時に自動インデントを無効にする http://bit.ly/IhAnBe {{{
if &term =~# 'xterm' && !has('nvim')
  " nvim は何もしなくても自動でpaste/nopasteしてくれるっぽい？
  let &t_ti .= "\e[?2004h"
  let &t_te .= "\e[?2004l"
  let &pastetoggle = "\e[201~"
  function! XTermPasteBegin(ret) abort
    setlocal paste
    return a:ret
  endfunction
  " mappings
  noremap <special> <expr> <Esc>[200~ XTermPasteBegin('0i')
  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin('')
  cnoremap <special> <Esc>[200~ <nop>
  cnoremap <special> <Esc>[201~ <nop>
endif " }}}
" マップ定義 {{{
" F2,F3でバッファ切り替え、F4でバッファ削除 {{{
map <F2> <ESC>:bp<CR>
map <F3> <ESC>:bn<CR>
map <F4> <ESC>:bw<CR>
" }}}
" 表示行単位で行移動する {{{
nnoremap j gj
onoremap j gj
xnoremap j gj
nnoremap k gk
onoremap k gk
xnoremap k gk
nnoremap <Down> gj
onoremap <Down> gj
xnoremap <Down> gj
nnoremap <Up> gk
onoremap <Up> gk
xnoremap <Up> gk
" }}}
" C-a, C-eで行頭行末に移動する {{{
inoremap <C-a> <ESC>^i
inoremap <C-e> <ESC>$i
" }}}
" VISUALモードでインデント操作後に選択範囲を保つ {{{
vnoremap = =gv
vnoremap > >gv
vnoremap < <gv
" }}}
" C-c でMacのクリップボードにコピーする {{{
if dein#util#_is_mac()
  " 無名レジスタ""の内容をpbcopyに渡す
  nmap <C-c> :call system('pbcopy', getreg('"'))<CR>
  " 選択範囲をyankして、更にヤンク内容が入りたての無名レジスタをpbcopyに渡す
  vmap <C-c> y:call system('pbcopy', getreg('"'))<CR>
endif " }}}
" }}} マップ定義

" }}}

" " ファイルタイプ関連
" NeoBundle 'Markdown'
" NeoBundle 'pangloss/vim-javascript'
" NeoBundle 'mxw/vim-jsx'
"
" NeoBundle 'sgur/vim-gf-autoload', {'depends': ['kana/vim-gf-user']}
"
" " 補完の凄いやつ
" NeoBundle 'Shougo/neocomplete'
"   " Disable AutoComplPop.
"   let g:acp_enableAtStartup = 0
"   " Use neocomplete.
"   let g:neocomplete#enable_at_startup = 1
"   " Use smartcase.
"   let g:neocomplete#enable_smart_case = 1
"   " Set minimum syntax keyword length.
"   let g:neocomplete#sources#syntax#min_keyword_length = 3
"   let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
"
"   " Define dictionary.
"   let g:neocomplete#sources#dictionary#dictionaries = {
"       \ 'default' : '',
"       \ 'vimshell' : $HOME.'/.vimshell_hist',
"       \ 'scheme' : $HOME.'/.gosh_completions'
"           \ }
"
"   " Define keyword.
"   if !exists('g:neocomplete#keyword_patterns')
"       let g:neocomplete#keyword_patterns = {}
"   endif
"   let g:neocomplete#keyword_patterns['default'] = '\h\w*'
"
"   " Plugin key-mappings.
"   inoremap <expr><C-g>     neocomplete#undo_completion()
"   inoremap <expr><C-l>     neocomplete#complete_common_string()
"
"   " Recommended key-mappings.
"   " <CR>: close popup and save indent.
"   inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
"   function! s:my_cr_function()
"     "return neocomplete#close_popup() . "\<CR>"
"     " For no inserting <CR> key.
"     return pumvisible() ? neocomplete#close_popup() : "\<CR>"
"   endfunction
"   " <TAB>: completion.
"   inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"   " <C-h>, <BS>: close popup and delete backword char.
"   inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
"   inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
"   inoremap <expr><C-y>  neocomplete#close_popup()
"   inoremap <expr><C-e>  neocomplete#cancel_popup()
"   " Close popup by <Space>.
"   "inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"
"
"   " For cursor moving in insert mode(Not recommended)
"   "inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
"   "inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
"   "inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
"   "inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
"   " Or set this.
"   "let g:neocomplete#enable_cursor_hold_i = 1
"   " Or set this.
"   "let g:neocomplete#enable_insert_char_pre = 1
"
"   " AutoComplPop like behavior.
"   "let g:neocomplete#enable_auto_select = 1
"
"   " Shell like behavior(not recommended).
"   "set completeopt+=longest
"   "let g:neocomplete#enable_auto_select = 1
"   "let g:neocomplete#disable_auto_complete = 1
"   "inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"
"
"   " Enable omni completion.
"   autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"   autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"   autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"   autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"   autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
"
"   " Enable heavy omni completion.
"   if !exists('g:neocomplete#sources#omni#input_patterns')
"     let g:neocomplete#sources#omni#input_patterns = {}
"   endif
"   "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"   "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"   "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
"
"   " For perlomni.vim setting.
"   " https://github.com/c9s/perlomni.vim
"   let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
"
" "" golang
" " golang関連の設定をいい感じにしてくれる（初めては最初に :GoInstallBinaries を実行する）
" NeoBundle 'fatih/vim-go'
"   "" <C-x><C-o> で関数名とかの補完発動
"   "" :Errors でエラー一覧
"   " mappings
"   au FileType go nmap <Leader>s <Plug>(go-implements)
"   au FileType go nmap <Leader>i <Plug>(go-info)
"   au FileType go nmap <Leader>gd <Plug>(go-doc)
"   au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
"   au FileType go nmap <Leader>gb <Plug>(go-doc-browser)
"   au FileType go nmap <leader>r <Plug>(go-run)
"   au FileType go nmap <leader>b <Plug>(go-build)
"   au FileType go nmap <leader>t <Plug>(go-test)
"   au FileType go nmap <leader>c <Plug>(go-coverage)
"   au FileType go nmap gd <Plug>(go-def)
"   au FileType go nmap <Leader>ds <Plug>(go-def-split)
"   au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
"   au FileType go nmap <Leader>dt <Plug>(go-def-tab)
"   au FileType go nmap <Leader>e <Plug>(go-rename)
"   " Enable hilight
"   let g:go_highlight_functions = 1
"   let g:go_highlight_methods = 1
"   let g:go_highlight_structs = 1
"
" NeoBundle "garyburd/go-explorer"
" if executable("go") && !executable("getool")
"   echo "install getool..."
"   call system("go get -u github.com/garyburd/go-explorer/src/getool")
" endif
"
"
"
" " gitが捗る http://d.hatena.ne.jp/cohama/20130517/1368806202
" NeoBundle 'gregsexton/gitv', {'depends': ['tpope/vim-fugitive']}
"   " gitvバッファ専用設定
"   autocmd FileType gitv call s:my_gitv_settings()
"   function! s:my_gitv_settings()
"     " t でdiffのフォルディングを開閉
"     nnoremap <silent><buffer> t :<C-u>windo call <SID>toggle_git_folding()<CR>1<C-w>w
"     " git操作を簡単にするmap
"     nnoremap <buffer> <Space>rb :<C-u>Git rebase <C-r>=GitvGetCurrentHash()<CR><Space>
"     nnoremap <buffer> <Space>R :<C-u>Git revert <C-r>=GitvGetCurrentHash()<CR><CR>
"     nnoremap <buffer> <Space>h :<C-u>Git cherry-pick <C-r>=GitvGetCurrentHash()<CR><CR>
"     nnoremap <buffer> <Space>rh :<C-u>Git reset --hard <C-r>=GitvGetCurrentHash()<CR>
"   endfunction
"   " gitバッファのフォルディングをトグルする関数
"   autocmd FileType git setlocal nofoldenable foldlevel=0
"   function! s:toggle_git_folding()
"     if &filetype ==# 'git'
"       setlocal foldenable!
"     endif
"   endfunction
"   " gitvバッファでカレント行のハッシュ値を取得する関数
"   function! s:gitv_get_current_hash()
"     return matchstr(getline('.'), '\[\zs.\{7\}\ze\]$')
"   endfunction
"



" "バイナリ編集(xxd)モード（vim -b での起動、もしくは *.bin で発動します）
" augroup BinaryXXD
"   autocmd!
"   autocmd BufReadPre  *.bin let &binary =1
"   autocmd BufReadPost * if &binary | silent %!xxd -g 1
"   autocmd BufReadPost * set ft=xxd | endif
"   autocmd BufWritePre * if &binary | %!xxd -r | endif
"   autocmd BufWritePost * if &binary | silent %!xxd -g 1
"   autocmd BufWritePost * set nomod | endif
" augroup END



