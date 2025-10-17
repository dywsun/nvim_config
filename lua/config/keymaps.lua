local keymap = vim.api.nvim_set_keymap -- Shorten function name
-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c'

local noremap_opts = { noremap = true, silent = true }
local slient_opts = { silent = true }

local allnoremap = function(lhs, rhs) keymap("", lhs, rhs, noremap_opts) end
local nnoremap = function(lhs, rhs, silent)
  if type(rhs) == "function" then
    vim.keymap.set("n", lhs, rhs)
  else
    silent = silent == nil or false
    noremap_opts.silent = silent
    keymap("n", lhs, rhs, noremap_opts)
  end
end
local vnoremap = function(lhs, rhs, silent)
  silent = silent == nil or false
  noremap_opts.silent = silent
  keymap("v", lhs, rhs, noremap_opts)
end
local xnoremap = function(lhs, rhs, silent)
  silent = silent == nil or false
  noremap_opts.silent = silent
  keymap("x", lhs, rhs, noremap_opts)
end
local nmap = function(lhs, rhs) keymap("n", lhs, rhs, slient_opts) end

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

-- table
-- nnoremap('<leader>tu', '<cmd>tabe<CR>')
-- nnoremap('<leader>tl', '<cmd>+tabnext<CR>')
-- nnoremap('<leader>th', '<cmd>-tabnext<CR>')

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

-- vnoremap('<leader>b', ':lua require("translate").trans()<CR>')

-- winshift
nmap("<C-h>", ":WinShift<CR>Jq<leader>k")
nmap("<C-l>", ":WinShift<CR>Lq<leader>h")

-- telescope
nnoremap("<leader>sj", "<cmd>Telescope find_files<CR>")
nnoremap("<leader>sk", "<cmd>Telescope treesitter<CR>")
nnoremap("<leader>sh", "<cmd>Telescope current_buffer_fuzzy_find<CR>")
nnoremap(
  "<leader>sv",
  '<cmd>lua require("plugins.mytelescope").nvim_config()<CR>'
)
nnoremap(
  "<leader>sz",
  '<cmd>lua require("plugins.mytelescope").zsh_config()<CR>'
)
nnoremap("<leader>sx", '<cmd>lua require("plugins.mytelescope").xconfig()<CR>')
nnoremap(
  "<leader>sp",
  '<cmd>lua require("plugins.mytelescope").select_project()<CR>'
)
nnoremap(
  "<leader>ss",
  '<cmd>lua require("plugins.mytelescope").search_string()<CR>'
)
nnoremap(
  "<leader>sc",
  '<cmd>lua require("plugins.mytelescope").change_cwd()<CR>'
)
nnoremap("<leader>sf", "<Cmd>TSToolsRemoveUnusedImports<CR>")
nnoremap("<leader>sm", "<Cmd>TSToolsRemoveUnused<CR>")

nnoremap(
  "<leader>cp",
  '<Cmd>lua require("wintersun.plugins.cocosframe").copy_popup()<CR>'
)
nnoremap(
  "<leader>ck",
  '<Cmd>lua require("wintersun.plugins.cocosframe").remove_popup()<CR>'
)

-- toggle terminal
nnoremap("<leader>sfl", "<cmd>ToggleTerm direction=vertical<CR>")
nnoremap("<leader>sfj", "<cmd>ToggleTerm direction=horizontal<CR>")

-- toggle markdown preview
nnoremap("<leader>mt", "<cmd>RenderMarkdown toggle<CR>")

-- source my snips config
-- nnoremap('<leader>ss', '<cmd>source ~/.config/nvim/after/plugin/mysnips.lua<CR>')
