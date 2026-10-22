vim.diagnostic.config({
  -- disable virtual text
  virtual_text = false,
  virtual_lines = false,
  -- virtual_lines = {
  --   current_line = true
  -- },
  -- show signs
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = "Error",
      [vim.diagnostic.severity.WARN] = "Warn",
      [vim.diagnostic.severity.INFO] = "Info",
      [vim.diagnostic.severity.HINT] = "Hint",
    },
  },
  update_in_insert = false,
  underline = true,
  float = {
    border = "rounded",
    source = true,
    prefix = "  ",
  },
  -- severity_sort = true,
})

local utils = require("utils")

utils.nnoremap(
  "<c-K>",
  "<cmd>lua vim.diagnostic.jump({count=-1,float=true})<CR>",
  "Go to previous diagnostic message"
)
utils.nnoremap(
  "<c-J>",
  "<cmd>lua vim.diagnostic.jump({count=1,float=true})<CR>",
  "Go to previous diagnostic message"
)

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api
        .nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match("%s")
      == nil
end

local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({})

local lspkind = require("lspkind")
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  completion = {
    -- The number of characters needed to trigger auto-completion.
    keyword_length = 1,
    -- match pattern
    -- keyword_pattern : string
  },
  mapping = cmp.mapping.preset.insert({
    -- `i` = insert mode, `c` = command mode, `s` = select mode
    ["<C-h>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<C-l>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<C-e>"] = cmp.mapping(function(fallback)
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      else
        fallback()
      end
    end, { "i", "s" }),

    -- ['<c-y>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false }),
    ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
    ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
    ["<C-p>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    ["<C-n>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    ["<C-;>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    -- ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    -- ["<C-e>"] = cmp.mapping {
    -- 	i = cmp.mapping.abort(),
    -- 	c = cmp.mapping.close(),
    -- },
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    -- ['<C-j>'] = cmp.mapping.confirm({ select = true }),
  }),

  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",
      maxwidth = {
        menu = 50,
        abbr = 50,
      },
      ellipsis_char = "...",
      show_labelDetails = true,

      before = function(entry, vim_item)
        local source_names = {
          nvim_lsp = "[LSP]",
          nvim_lua = "[API]",
          treesitter = "[TS]",
          emoji = "[Emoji]",
          path = "[Path]",
          calc = "[Calc]",
          cmp_tabnine = "[Tabnine]",
          vsnip = "[Snip]",
          luasnip = "[Snip]",
          buffer = "[Buffer]",
          spell = "[Spell]",
        }
        vim_item.menu = source_names[entry.source.name]
        return vim_item
      end,
    }),
  },

  sources = cmp.config.sources({
    -- { name = 'fittencode', group_index = 1 },
    { name = "lazydev", group_index = 0 },
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "treesitter" },
    { name = "buffer" },
    { name = "path" },
    { name = "spell" },
    { name = "nvim_lsp_signature_help" },
  }),
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  -- view = {
  --   entries = 'native'
  -- },
  experimental = {
    ghost_text = false,
  },
})

-- Use buffer source for `/`
cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})

require("mason").setup({
  max_concurrent_installers = 10,
  github = {
    download_url_template = vim.g.github_url .. "%s/releases/download/%s/%s",
  },
})

local win_servers = {
  "lua_ls",
  "ts_ls",
  "jsonls",
}
local linux_servers = {
  "lua_ls",
  "stylua",
  "ts_ls",
  "jsonls",
  "neocmake",
  "ccls",
  "bashls",
  "tombi",
}

local servers = utils.os_name() == "Windows" and win_servers or linux_servers

require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_filter(
    function(item) return item ~= "ccls" end,
    servers
  ),
  automatic_enable = false,
})

vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

for _, server in ipairs(servers) do
  if server ~= "ts_ls" then vim.lsp.enable(server) end
end

require("typescript-tools").setup({
  settings = {
    tsserver_file_preferences = {
      includeInlayParameterNameHints = "all",
      includeCompletionsForModuleExports = true,
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(args)
    local function nmap(keys, func, desc)
      if desc then desc = "LSP: " .. desc end
      local options = { noremap = true, silent = true, desc = desc }
      vim.api.nvim_buf_set_keymap(args.buf, "n", keys, func, options)
    end

    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    if client:supports_method("textDocument/references") then
      nmap(
        "grr",
        '<cmd>lua require("telescope.builtin").lsp_references()<CR>',
        "goto references"
      )
    end

    if client:supports_method("textDocument/definition") then
      nmap(
        "gd",
        '<cmd>lua require("telescope.builtin").lsp_definitions()<CR>',
        "goto definitions"
      )
    end

    if client:supports_method("textDocument/implementation") then
      nmap(
        "gri",
        '<cmd>lua require("telescope.builtin").lsp_implementations()<CR>',
        "goto type definitions"
      )
    end

    if client:supports_method("textDocument/documentHighlight") then
      nmap("K", "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover Documentation")
    end

    if client:supports_method("textDocument/formatting") then
      vim.keymap.set(
        "n",
        "<leader>f",
        function() vim.lsp.buf.format({ bufnr = args.buf }) end,
        {
          noremap = true,
          silent = true,
          desc = "LSP: Formatting",
          buffer = args.buf,
        }
      )
    end

    if client:supports_method("textDocument/documentSymbol") then
      nmap(
        "grs",
        '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>',
        "goto document symbols"
      )
    end

    nmap(
      "grd",
      '<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>',
      "goto dynamic workspace symbols"
    )

    if client.name == "typescript-tools" then
      nmap("<leader>sf", "<Cmd>TSToolsRemoveUnusedImports<CR>")
      nmap("<leader>sm", "<Cmd>TSToolsRemoveUnused<CR>")
    end

    -- if client:supports_method('textDocument/completion') then
    --   -- Optional: trigger autocompletion on EVERY keypress. May be slow!
    --   -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
    --   -- client.server_capabilities.completionProvider.triggerCharacters = chars
    --   vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    -- end
  end,
})
