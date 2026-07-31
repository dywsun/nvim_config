local treesitter_win = {
  "lua",
  "typescript",
  "javascript",
  "json",
  "html",
  "csv",
  "vimdoc",
}

local treesitter_linux = {
  "lua",
  "typescript",
  "javascript",
  "json",
  "html",
  "csv",
  "bash",
  "cmake",
  "c",
  "cpp",
  "vim",
  "vimdoc",
}

return {
  { "nvim-lua/plenary.nvim" },
  -- colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 999,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  {
    "sainnhe/gruvbox-material",
    config = function() vim.cmd [[colorscheme gruvbox-material]] end,
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
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      { "j-hui/fidget.nvim", tag = "legacy", opts = {} },

      -- Snippet Engine & its associated nvim-cmp source
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",

      -- Adds LSP completion capabilities
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",

      -- Adds a number of user-friendly snippets
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
  },

  -- typescript lsp
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },

  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    lazy = false,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require "nvim-treesitter.configs".setup {
        ensure_installed = require("utils").os_name() == "Windows"
            and treesitter_win
          or treesitter_linux,
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
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
    requires = "nvim-treesitter/nvim-treesitter",
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    after = "nvim-treesitter",
    requires = "nvim-treesitter/nvim-treesitter",
  },
  -- {
  --   "nvim-treesitter/nvim-treesitter-refactor",
  --   after = "nvim-treesitter",
  --   requires = "nvim-treesitter/nvim-treesitter",
  -- },
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "InsertEnter",
  --   opts = {
  --     -- cfg options
  --   },
  -- },
  require "plugins.telescope",
  require "plugins.lualine",
  -- comment
  {
    "numToStr/Comment.nvim",
    config = function() require("Comment").setup() end,
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
      -- format_on_save = { timeout_ms = 100 },
    },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    opts = {},
  },

}
