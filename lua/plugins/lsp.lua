return {
  -- clangd = {},
  -- rust_analyzer = {},
  gopls = {},
  pyright = {},
  html = { filetypes = { 'html', 'twig', 'hbs' } },
  ["typescript-tools"] = {
    filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }
  },
  -- ts_ls = {},
  lua_ls = {
    Lua = {
      workspace = {
        library = {
          "${3rd}/love2d/library",
        },
      },
      -- workspace = { checkThirdParty = false },
      -- telemetry = { enable = false },
    },
  },
  cmake = {},
  jsonls = {},
  ccls = {
    init_options = {
      -- compilationDatabaseDirectory = "build",
      -- index = {
      --   threads = 0;
      -- },
      -- clang = {
      --   excludeArgs = { "-frounding-math"} ;
      -- },
      cache = {
        directory = '/tmp/ccls_cache'
      }
    },

    cmd = { 'ccls' },
    filetypes = { 'c', 'cc', 'cpp', 'objc', 'objcpp', 'cuda' },
    offset_encoding = 'utf-8',
    -- root_dir = root_pattern('compile_commands.json', '.ccls', '.git'),
    -- ccls does not support sending a null root directory
    single_file_support = false,
  }
}
