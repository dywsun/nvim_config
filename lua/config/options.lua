local options = {
  mouse = '',       -- disable mouse
  winbar = '%=%m %f ',
  laststatus = 3,   -- global status line
  showmode = false, -- undisplay insert/virsual/... mode ui

  title = true,
  cursorline = true, -- hightlight current cursor line
  guicursor = '',

  expandtab = true,
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 2,
  smartindent = true,

  errorbells = false,

  encoding = 'utf-8',

  wrap = true,
  number = true,
  numberwidth = 4,

  incsearch = true,
  ignorecase = true,
  smartcase = true,
  hlsearch = true,

  timeoutlen = 400, -- timeout for keymaps

  swapfile = false,
  -- backup = false,
  -- undodir = '~/.config/nvim/undodir',
  undofile = true,

  signcolumn = 'yes',
  colorcolumn = '80',
  scrolloff = 8,

  -- interval for writing swap file to disk, also used by gitsigns
  updatetime = 30,

  -- give move space for display message
  -- cmdheight = 2,

  backspace = 'indent,eol,start',

  termguicolors = true,

  -- disable automatic folding of files when open files
  foldmethod = 'syntax',
  foldlevelstart = 99
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.opt.shortmess:append('c')

-- set background color
-- vim.cmd [[ highlight Normal guibg=none ]]
