local M = {}

function M.os_name()
  local sysname = vim.uv.os_uname().sysname
  if sysname:find("Windows") ~= nil then
    return "Windows"
  else
    if sysname == "Darwin" or sysname == "Linux" then return sysname end
  end
end

local keymap = vim.api.nvim_set_keymap
-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c'

local noremap_opts = { noremap = true, silent = true }
local slient_opts = { silent = true }
function M.allnoremap(lhs, rhs) keymap("", lhs, rhs, noremap_opts) end

function M.nnoremap(lhs, rhs, silent)
  if type(rhs) == "function" then
    vim.keymap.set("n", lhs, rhs)
  else
    silent = silent == nil or false
    noremap_opts.silent = silent
    keymap("n", lhs, rhs, noremap_opts)
  end
end

function M.vnoremap(lhs, rhs, silent)
  silent = silent == nil or false
  noremap_opts.silent = silent
  keymap("v", lhs, rhs, noremap_opts)
end

function M.xnoremap(lhs, rhs, silent)
  silent = silent == nil or false
  noremap_opts.silent = silent
  keymap("x", lhs, rhs, noremap_opts)
end

function M.nmap(lhs, rhs) keymap("n", lhs, rhs, slient_opts) end

return M
