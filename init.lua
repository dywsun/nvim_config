-- vim.g.mirror_github_url = "https://ghproxy.cfd/https://github.com/"
vim.g.github_url = vim.g.mirror_github_url or "https://github.com/"

require("options")
require("keymaps")

-- lazy: plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    vim.g.github_url .. "folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = require("plugins")
local opts = {
  git = {
    log = { "-8" },
    timeout = 120,
    url_format = vim.g.github_url .. "%s.git",
    filter = true,
  },
}

require("lazy").setup(plugins, opts)
require("lsp")

-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("UserHighlightYank", { clear = true }),
  callback = function() vim.hl.on_yank({ higroup = "Visual" }) end,
})
