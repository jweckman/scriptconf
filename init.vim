syntax on
set rnu
set nu rnu
" Use below setting if no plugins are available. Allows vanilla fuzzy finding
"set path +=**
set wildmenu
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set noswapfile
set incsearch
set ignorecase
set updatetime=300
set shortmess+=c
"set foldmethod=syntax
set lazyredraw
set foldnestmax=10
set nofoldenable
set foldlevel=2
let mapleader=","
nnoremap gv <c-v>
set hidden
nnoremap <C-L> :bnext<CR>
nnoremap <C-H> :bprev<CR>
" Try to prettify the builtin way
map <leader>pp gg=G<C-o><C-o>
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

" Line diff configs. Allows for comparing the @a and @b register contents
noremap <leader>ldt :Linediff<CR>
noremap <leader>ldo :LinediffReset<CR>

let g:diffed_buffers = []

function DiffText(a, b, diffed_buffers)
    enew
    setlocal buftype=nowrite
    call add(a:diffed_buffers, bufnr('%'))
    call setline(1, split(a:a, "\n"))
    diffthis
    vnew
    setlocal buftype=nowrite
    call add(a:diffed_buffers, bufnr('%'))
    call setline(1, split(a:b, "\n"))
    diffthis
endfunction

function WipeOutDiffs(diffed_buffers)
    for buffer in a:diffed_buffers
        execute 'bwipeout! ' . buffer
    endfor
endfunction

nnoremap <leader>ldr :call DiffText(@a, @b, g:diffed_buffers)<CR>
"nnoremap <leader>ldrr :call WipeOutDiffs(g:diffed_buffers) | let g:diffed_buffers=[]<CR>

" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" Plug
call plug#begin('~/.vim/plugged')
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary/'
    Plug 'mechatroner/rainbow_csv'
    Plug 'ap/vim-buftabline'
    Plug 'vimwiki/vimwiki'
    Plug 'AndrewRadev/linediff.vim'
    " Telescope
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-fzy-native.nvim'
    " Treesitter
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/playground'
    " LSP
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/nvim-compe'
    Plug 'simrat39/rust-tools.nvim'
    Plug 'ray-x/lsp_signature.nvim'
call plug#end()

" Vim Wiki
let g:vimwiki_list = [{'path': '/rpi2tb/joakim/documents/wiki', 'syntax': 'markdown'}]
au FileType vimwiki setlocal shiftwidth=6 tabstop=6 noexpandtab

" Telescope configs

nnoremap <leader>fb :lua require('telescope.builtin').file_browser{}<CR>
nnoremap <leader>fbb :lua require('telescope.builtin').file_browser{cwd = '%:h'}<CR>
nnoremap <leader>lb :lua require('telescope.builtin').buffers{}<CR>
nnoremap <leader>ff :lua require('telescope.builtin').find_files{ find_command = {'rg', '--files', '--hidden', '-g', '!*.{xls,xlsx,pdf,rbql,po}'} }<CR>
nnoremap <leader>fg :lua require('telescope.builtin').live_grep{}<CR>
nnoremap <leader>fgg :lua require('telescope.builtin').live_grep{search_dirs = {'%:h'}}<CR>

" LSP and Treesitter configs
lua << EOF

-- LSP signature plugin setup
require "lsp_signature".setup()

-- Languages setup
require'lspconfig'.pyright.setup{}
require'lspconfig'.texlab.setup{}
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.jsonls.setup {
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line("$"),0})
        end
      }
    }
}

-- LSP global keymaps
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>sh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

-- Treesitter
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = false,
    disable = {},
  },
  ensure_installed = {
    "python",
    "rust",
    "json",
    "yaml",
    "html",
  },
}
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.used_by = { "javascript", "typescript.tsx", "python" }

-- Compe
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
  };
}
vim.o.completeopt = "menuone,noselect"

EOF
