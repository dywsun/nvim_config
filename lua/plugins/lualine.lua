return {
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      -- Color table for highlights
      -- stylua: ignore
      local colors = {
        bg       = '#202328',
        gray     = '#ABB2BF',
        fg       = '#bbc2cf',
        yellow   = '#ECBE7B',
        cyan     = '#008080',
        darkblue = '#081633',
        green    = '#98c379',
        -- green    = '#98be65',
        orange   = '#FF8800',
        violet   = '#a9a1e1',
        magenta  = '#c678dd',
        blue     = '#51afef',
        red      = '#ec5f67',
      }

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
          local filepath = vim.fn.expand('%:p:h')
          local gitdir = vim.fn.finddir('.git', filepath .. ';')
          return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
      }

      -- `branch` (git branch)
      -- `buffers` (shows currently available buffers)
      -- `diagnostics` (diagnostics count from your preferred source)
      -- `diff` (git diff status)
      -- `encoding` (file encoding)
      -- `fileformat` (file format)
      -- `filename`
      -- `filesize`
      -- `filetype`
      -- `hostname`
      -- `location` (location in file in line:column format)
      -- `mode` (vim mode)
      -- `progress` (%progress in file)
      -- `tabs` (shows currently available tabs)
      -- `windows` (shows currently available windows)

      -- custom session
      -- local mysession = {
      -- 	'mode',
      -- 	icons_enabled = true,
      -- 	icon = {
      -- 		'icon',
      -- 		align = 'left', -- or 'right'
      -- 		color = {
      -- 			fg = ''
      -- 		}
      -- 	},
      -- 	separator = {
      -- 		left = '',
      -- 		right = ''
      -- 	},
      -- 	cond = {
      -- 	},
      -- 	color = {
      -- 		fg = '',
      -- 		bg = '',
      -- 		gui = ''
      -- 	},
      -- 	-- type = '',
      -- 	padding = {
      -- 		left = 1,
      -- 		right = 1
      -- 	},
      -- 	fmt = function(str)
      -- 		return str
      -- 	end
      -- 	-- on_click = nil -- for mouse click
      -- }

      -- Config
      local config = {
        options = {
          -- Disable sections and component separators
          component_separators = { left = '', right = '' },
          section_separators = '',
          -- theme = 'auto',
          -- theme = {
          --   -- We are going to use lualine_c an lualine_x as left and
          --   -- right section. Both are highlighted by c theme .  So we
          --   -- are just setting default looks o statusline
          --   normal = { c = { fg = colors.fg, bg = colors.bg } },
          --   inactive = { c = { fg = colors.fg, bg = colors.bg } },
          -- },
          disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
          ignore_focus = { "alpha", "dashboard", "NvimTree", "Outline" },
          globalstatus = true,
          icons_enabled = true,
          --theme = 'gruvbox-material'
          theme = 'tokyonight'
        },
        sections = {
          -- these are to remove the defaults
          lualine_a = {
            {
              'mode',
              icon = {
                '',
                align = 'left',
                color = {
                  fg = colors.green,
                  gui = 'bold',
                }
              },
              separator = { left = '', right = '' },
              fmt = string.upper,
              color = {
                gui = 'bold',
              }
            },
          },
          lualine_b = {
            {
              'filetype',
              colored = true,
              icon_only = true,
            },
            {
              'filename',
              color = {
                fg = colors.bg,
                bg = colors.magenta,
                gui = 'bold'
              },
            },
            {
              'branch',
              icon = {
                '',
                color = {
                  gui = 'bold'
                }
              },
              -- separator = { right = '' },
              color = {
                fg = colors.bg,
                bg = '#98c379',
                gui = 'italic,bold'
              }
            },
            {
              'diff',
              colored = true,
              diff_color = {
                added = { fg = colors.green },
                modified = { fg = colors.orange },
                removed = { fg = colors.red },
              },
              symbols = { added = ' ', modified = ' ', removed = ' ' },
            },
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
              symbols = { error = ' ', warn = ' ', info = ' ' },
              diagnostics_color = {
                color_error = { fg = colors.red },
                color_warn = { fg = colors.yellow },
                color_info = { fg = colors.cyan },
              },
              colored = true,
              always_visible = false
            },
            {
              -- Lsp server name .
              function()
                local msg = 'No Lsp'
                -- local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                -- local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if next(clients) == nil then
                  return msg
                end
                local client_name = clients[1].name
                if client_name == 'typescript-tools' then
                  client_name = 'ts_ls'
                end
                return client_name
              end,
              color = { fg = colors.bg, bg = colors.blue, gui = 'bold' },
              -- separator = { left = '', right = '' }, --
            },
            {
              'fileformat',
              fmt = string.upper,
              icons_enabled = true,
              color = {
                fg = colors.bg,
                bg = colors.yellow,
                gui = 'bold'
              },
              symbols = {
                unix = ' LF',
                dos = ' CRLF',
                mac = ' CR',
              },
              -- separator = { left = '', right = '' }, --
            },
            {
              'o:encoding',       -- option component same as &encoding in viml
              fmt = string.upper, -- I'm not sure why it's upper case either ;)
              cond = conditions.hide_in_width,
              color = {
                fg = colors.bg,
                bg = colors.green,
                gui = 'bold'
              },
            },
          },
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {
            {
              'filesize',
              color = {
                fg = colors.violet,
                -- bg = colors.green
                gui = 'bold'
              },
              cond = conditions.buffer_not_empty,
            },
            {
              'location',
              color = {
                fg = colors.bg,
                bg = colors.blue,
                gui = 'bold'
              },
            },
            {
              'progress',
              color = {
                fg = colors.bg,
                bg = colors.yellow,
                gui = 'bold',
              },
              cond = conditions.hide_in_width,
            },
          },
        },
      }

      -- Now don't forget to initialize lualine
      require('lualine').setup(config)
    end
  }
}
