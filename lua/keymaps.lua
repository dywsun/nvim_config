local utils = require("utils")
local allnoremap = utils.allnoremap
local nnoremap = utils.nnoremap
local vnoremap = utils.vnoremap
local xnoremap = utils.xnoremap

--Remap space as leader key
allnoremap("<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- better save(quit,refresh) file
nnoremap("<leader>w", "<cmd>w<CR>")
nnoremap("<leader>q", "<cmd>q<CR>")
nnoremap("<leader>a", "<cmd>qall<CR>")
nnoremap("<leader>z", '<cmd>source %<CR><cmd>echo "This file is sourced!"<CR>')

-- split window operations
nnoremap("<leader>sr", "<cmd>set splitright<CR><cmd>vsp<CR>")
nnoremap("<leader>sl", "<cmd>set nosplitright<CR><cmd>vsp<CR>")
nnoremap("<leader>su", "<cmd>set nosplitbelow<CR><cmd>sp<CR>")
nnoremap("<leader>sd", "<cmd>set splitbelow<CR><cmd>sp<CR>")

-- move window
nnoremap("<leader>l", "<C-w>l")
nnoremap("<leader>k", "<C-w>k")
nnoremap("<leader>j", "<C-w>j")
nnoremap("<leader>h", "<C-w>h")

-- resize with arrows
nnoremap("<up>", "<cmd>resize -3<CR>")
nnoremap("<down>", "<cmd>resize +3<CR>")
nnoremap("<left>", "<cmd>vertical resize -3<CR>")
nnoremap("<right>", "<cmd>vertical resize +3<CR>")

-- line numbers
-- nnoremap('<leader>n', '<cmd>set nu!<CR>')
nnoremap("<leader>n", "<cmd>set rnu!<CR>")

-- netrw
-- nnoremap('<leader>t', '<cmd>Ex<CR>')
nnoremap("<leader>t", "<cmd>Oil<CR>")

-- format
nnoremap("<leader>f", vim.lsp.buf.format)

-- unhighlight search
nnoremap("<esc>", "<cmd>noh<CR>")

-- copy with clipboard
vnoremap("<leader>y", [["+y]])
nnoremap("<leader>y", [["+y]])
nnoremap("<leader>Y", [["+Y]])

-- greatest remap ever
xnoremap("<leader>p", [["_dP]])

-- keep the cursor position unchanged
nnoremap("J", "mzJ`z")

-- keep the cursor in the middle of the screen
nnoremap("<C-u>", "<C-u>zz")
nnoremap("<C-d>", "<C-d>zz")
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")

-- move visual text to anywhere
vnoremap("J", ":m '>+1<CR>gv=gv")
vnoremap("K", ":m '<-2<CR>gv=gv")

-- replace string
nnoremap(
  "<leader>sg",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  false
)

-- make excuteable
nnoremap("<leader>x", "<cmd>!chmod +x %<CR>")

-- toggle markdown preview
nnoremap("<leader>mt", "<cmd>RenderMarkdown toggle<CR>")

-- toggle terminal
-- nnoremap("<leader>sfl", "<cmd>ToggleTerm direction=vertical<CR>")
-- nnoremap("<leader>sfj", "<cmd>ToggleTerm direction=horizontal<CR>")

-- source my snips config
-- nnoremap('<leader>ss', '<cmd>source ~/.config/nvim/after/plugin/mysnips.lua<CR>')
