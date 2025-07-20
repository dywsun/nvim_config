local M = {}

function M.builtin()
  return require('telescope.builtin').builtin()
end

function M.nvim_config()
  require('telescope.builtin').find_files {
    prompt_title = "Neovim Config",
    shorten_path = false,
    cwd = vim.fn.stdpath('config')
    -- width = .25,
  }
end

function M.search_string()
  local search = vim.fn.input("Search: ")
  if search == nil or search == "" then search = "TODO" end
  require('telescope.builtin').live_grep({ default_text = search })
end

function M.select_project()
  require('telescope.builtin').find_files({
    prompt_title = "Select Project Root Directory",
    find_command = { "fd", "--type", "d", "--max-depth", "1", "--hidden", "--exclude", ".git" },
    cwd = 'D:/workspace/cocos_game/work/3.6.3',
    attach_mappings = function(_, map)
      map('i', "<CR>", function(prompt_bufnr)
        local actions = require('telescope.actions')
        local actions_state = require('telescope.actions.state')

        local selection = actions_state.get_selected_entry()
        if selection then
          local new_root = selection.path or selection[1]
          vim.api.nvim_set_current_dir(new_root)
        end
        actions.close(prompt_bufnr)
      end)
      return true
    end
  })
end

return M
