return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end
    }
  },
  config = function()
    local telescope = require("telescope")
    local telescope_config = require("telescope.config")

    -- Clone the default Telescope configuration
    local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }

    -- I want to search in hidden/dot files.
    -- table.insert(vimgrep_arguments, "--hidden")

    -- I don't want to search in the `.git` directory.
    table.insert(vimgrep_arguments, "--glob")
    table.insert(vimgrep_arguments, "!**/.git/*")

    -- Don't preview binaries
    local previewers = require("telescope.previewers")
    local Job = require("plenary.job")
    -- print(Job)
    local new_maker = function(filepath, bufnr, opts)
      filepath = vim.fn.expand(filepath)
      Job:new({
        command = "file",
        args = { "--mime-type", "-b", filepath },
        on_exit = function(j)
          local mime_type = vim.split(j:result()[1], "/", _)[1]
          if mime_type == "text" then
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
          else
            -- maybe we want to write something to the buffer here
            vim.schedule(function()
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
            end)
          end
        end
      }):sync()
    end
    telescope.setup {
      defaults = {
        -- buffer_previewer_maker = new_maker,
        -- Default configuration for telescope goes here:
        -- config_key = value,
        vimgrep_arguments = vimgrep_arguments,
        prompt_prefix = "  ",
        selection_caret = " ",
        sorting_strategy = "ascending",
        -- layout_strategy = "horizontal",
        -- layout_config = {
        --     horizontal = {
        --         prompt_position = "top",
        --         preview_width = 0.55,
        --         results_width = 0.8,
        --     },
        --     vertical = {
        --         -- width = 0.5,
        --         mirror = false,
        --     },
        --     width = 0.87,
        --     height = 0.80,
        --     preview_cutoff = 120,
        -- },
        color_devicons = true,
        -- path_display = { "truncate" },
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        results_title = '',
        mappings = {
          -- i: insert, n: normal
          i = {
            -- map actions.which_key to <C-h> (default: <C-/>)
            -- actions.which_key shows the mappings for your picker,
            -- e.g. git_{create, delete, ...}_branch for the git_branches picker
            -- ['<C-/>'] = 'which_key',
            ['<C-d>'] = false,
            ['<C-x>'] = false,
            ['<C-v>'] = false,
            ['<C-u>'] = false,
            ['<C-J>'] = 'move_selection_next',
            ['<C-k>'] = 'move_selection_previous',
            ['<C-n>'] = 'preview_scrolling_down',
            ['<C-p>'] = 'preview_scrolling_up',
            ['<C-l>'] = 'select_vertical',
            ['<C-h>'] = 'select_horizontal',
          }
        },
        preview = {
          filesize_limit = 0.1 -- MB
        }
      },
      pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
        find_files = {
          no_ignore = true,
          hidden = true,
          find_command = {
            'rg', '--files', '--hidden',
            '--glob', '!**/.git/*',
            '--glob', '!*.pac',
            '--glob', '!*.atlas',
            '--glob', '!*.png',
            '--glob', '!*.mp3',
            '--glob', '!*.prefab',
            '--glob', '!*.scene',
            '--glob', '!*.xlsx',
            '--glob', '!*.meta',
            '--glob', '!**/node_modules/*',
            '--glob', '!**/temp/*',
            '--glob', '!**/library/*',
          },
          theme = "dropdown",
          mappings = {
            n = {
              ["cd"] = function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                local dir = vim.fn.fnamemodify(selection.path, ":p:h")
                require("telescope.actions").close(prompt_bufnr)
                -- Depending on what you want put `cd`, `lcd`, `tcd`
                vim.cmd(string.format("silent lcd %s", dir))
              end
            }
          }
        },
        lsp_references = {
          theme = "dropdown",
        }
      },
      extensions = {
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        -- please take a look at the readme of the extension you want to configure
        fzf = {
          fuzzy = true,                   -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true,    -- override the file sorter
          case_mode = 'smart_case',       -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        }
      }
    }

    require('telescope').load_extension('fzf')
  end
}
