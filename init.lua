vim.g.mirror_github_url = "https://ghproxy.cfd/https://github.com/"
vim.g.github_url = vim.g.mirror_github_url or "https://github.com/"

require("config.lazy")
require("config.keymaps")
require("config.options")
