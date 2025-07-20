vim.diagnostic.config {
  -- disable virtual text
  virtual_text = true,
  -- virtual_lines = {
  --   current_line = true
  -- },
  -- -- show signs
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = 'Error',
      [vim.diagnostic.severity.WARN] = "Warn",
      [vim.diagnostic.severity.INFO] = "Info",
      [vim.diagnostic.severity.HINT] = "Hint",
    },
  },
  update_in_insert = false,
  underline = false,
  -- severity_sort = true,
}
local function nnoremap(keys, func, desc)
  local options = { noremap = true, silent = true, desc = desc }
  vim.api.nvim_set_keymap('n', keys, func, options)
end
nnoremap('<c-K>', '<cmd>lua vim.diagnostic.jump({count=-1})<CR>', 'Go to previous diagnostic message')
nnoremap('<c-J>', '<cmd>lua vim.diagnostic.jump({count=1})<CR>', 'Go to previous diagnostic message')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

local lspkind = require('lspkind')
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    -- The number of characters needed to trigger auto-completion.
    keyword_length = 1
    -- match pattern
    -- keyword_pattern : string
  },
  mapping = cmp.mapping.preset.insert {
    -- `i` = insert mode, `c` = command mode, `s` = select mode
    ['<C-h>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<C-l>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ['<C-e>'] = cmp.mapping(function(fallback)
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      else
        fallback()
      end
    end, { "i", "s" }),

    -- ['<c-y>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false }),
    ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
    ['<C-p>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-n>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-;>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    -- ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    -- ["<C-e>"] = cmp.mapping {
    -- 	i = cmp.mapping.abort(),
    -- 	c = cmp.mapping.close(),
    -- },
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    -- ['<C-j>'] = cmp.mapping.confirm({ select = true }),
  },

  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = {
        menu = 50,
        abbr = 50,
      },
      ellipsis_char = '...',
      show_labelDetails = true,

      before = function(entry, vim_item)
        local source_names = {
          nvim_lsp = '[LSP]',
          nvim_lua = '[API]',
          treesitter = '[TS]',
          emoji = '[Emoji]',
          path = '[Path]',
          calc = '[Calc]',
          cmp_tabnine = '[Tabnine]',
          vsnip = '[Snip]',
          luasnip = '[Snip]',
          buffer = '[Buffer]',
          spell = '[Spell]',
        }
        vim_item.menu = source_names[entry.source.name]
        return vim_item
      end
    })
  },

  sources = cmp.config.sources({
    -- { name = 'fittencode', group_index = 1 },
    { name = 'lazydev',   group_index = 0 },
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'treesitter' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'spell' },
  }),
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false
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
}

-- Use buffer source for `/`
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources(
    { { name = 'path' } },
    { { name = 'cmdline' } }
  ),
})

require 'mason'.setup {
  max_concurrent_installers = 10,
  github = { download_url_template = vim.g.github_url .. '%s/releases/download/%s/%s' }
}

require 'mason-lspconfig'.setup {
  -- ensure_installed = { "lua_ls", "jsonls", "pyright", "html" },
  ensure_installed = { "lua_ls" },
  automatic_enable = false
}

local on_attach = function(_, bufnr)
  local function nmap(keys, func, desc)
    if desc then desc = 'LSP: ' .. desc end
    local options = { noremap = true, silent = true, desc = desc }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', keys, func, options)
  end

  -- client.resolved_capabilities.code_action =
  nmap('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', '[R]e[n]ame')
  nmap('<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', '[C]ode [A]ction')

  nmap('gd', '<cmd>lua vim.lsp.buf.definition()<CR>', '[G]oto [D]efinition')
  nmap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', '[G]oto [I]mplementation')
  nmap('gr', '<cmd>lua require("telescope.builtin").lsp_references()<CR>', '[G]oto [R]eferences')
  nmap('<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', 'Type [D]efinition')
  nmap('<leader>ds', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', '[D]ocument [S]ymbols')
  nmap('<leader>ws', '<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>',
    '[W]orkspace [S]ymbols')
  nmap('K', '<cmd>lua vim.lsp.buf.hover()<CR>', 'Hover Documentation')
  -- nmap('<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', '[G]oto [D]eclaration')
  nmap('<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
local servers = require('plugins.lsp')
for server_name, _ in pairs(servers) do
  require('lspconfig')[server_name].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = servers[server_name],
    filetypes = (servers[server_name] or {}).filetypes,
  }
end
