return {
  { "nvim-lua/plenary.nvim" },
  -- add gruvbox
  { "sainnhe/gruvbox-material" },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    -- config = function() vim.cmd [[colorscheme gruvbox-material]] end,
  },
  -- Using Lazy
  {
    "navarasu/onedark.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('onedark').setup {
        style = 'darker'
      }
      require('onedark').load()
    end
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    -- Autocompletion
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        -- LSP Configuration & Plugins
        "neovim/nvim-lspconfig",
        dependencies = {
          -- Automatically install LSPs to stdpath for neovim
          { "williamboman/mason.nvim" },
          "williamboman/mason-lspconfig.nvim",
          { "j-hui/fidget.nvim",      tag = "legacy", opts = {} },
        },
      },
      -- Snippet Engine & its associated nvim-cmp source
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",

      -- Adds LSP completion capabilities
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",

      -- Adds a number of user-friendly snippets
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
  },
  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    lazy = false,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require "nvim-treesitter.configs".setup {
        ensure_installed = {
          "c",
          "cpp",
          "lua",
          "cmake",
          "csv",
          "awk",
          "bash",
          "vim",
          "vimdoc",
          "json",
          "typescript",
          "javascript",
          "html",
        },
        auto_install = true,
        sync_install = true,
        ignore_install = {},
        highlight = {
          enable = true,
          disable = {},
          additional_vim_regex_highlighting = false,
        },
        modules = {},
      }
    end,
  },
  require "plugins.telescope",
  require "plugins.lualine",
  -- typescript tools
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },

  -- comment
  {
    "numToStr/Comment.nvim",
    config = function() require "Comment".setup() end,
  },

  -- align text
  { "godlygeek/tabular" },
  { "tpope/vim-surround" },
  { "tpope/vim-repeat" },

  -- git integration
  {
    "tpope/vim-fugitive",
    cmd = { "G" },
    keys = {
      { "<leader>gs", "<cmd>G<cr>", desc = "Git status" },
    },
    lazy = true,
  },

  {
    "luozhiya/fittencode.nvim",
    opts = {},
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      -- Set default options
      default_format_opts = {
        lsp_format = "fallback",
      },
      -- Set up format-on-save
      format_on_save = { timeout_ms = 100 },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  -- {
  --   "nvim-treesitter/nvim-treesitter-textobjects",
  --   after = "nvim-treesitter",
  --   requires = "nvim-treesitter/nvim-treesitter",
  -- },
  -- {
  --   "nvim-treesitter/nvim-treesitter-context",
  --   after = "nvim-treesitter",
  --   requires = "nvim-treesitter/nvim-treesitter",
  -- },
  -- {
  --   "nvim-treesitter/nvim-treesitter-refactor",
  --   after = "nvim-treesitter",
  --   requires = "nvim-treesitter/nvim-treesitter",
  -- },

}
