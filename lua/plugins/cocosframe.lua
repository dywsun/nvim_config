local M = {}

-- custom command
local uv = vim.uv
local function mkdir_p(path)
  local sep = package.config:sub(1, 1)   -- 获取系统分隔符 ('/' or '\')
  local current = ""
  for part in string.gmatch(path, "[^" .. sep .. "]+") do
    current = current == "" and part or (current .. sep .. part)
    if not uv.fs_stat(current) then
      local ok, err = uv.fs_mkdir(current, 493)
      if not ok then
        print("创建目录失败: " .. err)
        return
      end
    end
  end
end

local function copy_file(src, dest)
  -- 打开源文件
  local src_fd = uv.fs_open(src, "r", 438)   -- 438 = 0666 in decimal
  if not src_fd then
    error("无法打开源文件: " .. src)
  end

  local stat = uv.fs_fstat(src_fd)
  local data = uv.fs_read(src_fd, stat.size, 0)
  uv.fs_close(src_fd)

  -- 创建目标文件
  local dest_fd = uv.fs_open(dest, "w", 438)
  if not dest_fd then
    error("无法创建目标文件: " .. dest)
  end

  uv.fs_write(dest_fd, data, 0)
  uv.fs_close(dest_fd)
end

local script_path = "assets/script/game/ui"
local ui_path = "assets/game_bundle/ui"
local path_config_file = "assets/script/game/core/Path.ts"
-- settingPopup: "ui/popup/setting/prefab/setting_popup",

local function capitalize_words(str, upper_first)
  upper_first = upper_first == nil and true or upper_first
  local words = vim.split(str, '_')
  for i, word in ipairs(words) do
    if (i ~= 1 or upper_first) then
      words[i] = string.upper(word:sub(1, 1)) .. word:sub(2)
    end
  end
  return table.concat(words)
  -- return string.gsub(str, "(%w)(%w*)", function(first, rest)
  --     return string.upper(first) .. string.lower(rest)
  -- end)
end
local function get_popup_script_path(name)
  return string.format("%s/popup/%sPopup.ts", script_path, capitalize_words(name))
end
local function get_popup_prefab_path(name)
  return string.format("%s/popup/%s/prefab/%s_popup.prefab", ui_path, name, name)
end
local function get_popup_config_path(name)
  return string.format('%sPopup: "ui/popup/%s/prefab/%s_popup"', capitalize_words(name, false), name, name)
end

function M.create_new_popup(src_name, dest_name)
  local src = get_popup_prefab_path(src_name)
  -- 打开源文件
  local src_fd = uv.fs_open(src, "r", 438)   -- 438 = 0666 in decimal
  if not src_fd then
    error("无法打开源文件: " .. src)
  end

  local stat = uv.fs_fstat(src_fd)
  local data = uv.fs_read(src_fd, stat.size, 0)
  uv.fs_close(src_fd)
  local result = string.gsub(
    data,
    string.format('"_name": "%s_popup"', src_name),
    string.format('"_name": "%s_popup"', dest_name)
  )

  local root = string.format("%s/popup/%s", ui_path, dest_name)
  mkdir_p(root)
  mkdir_p(root .. "/img")
  mkdir_p(root .. "/anim")
  mkdir_p(root .. "/prefab")

  local dest = get_popup_prefab_path(dest_name)
  local dest_fd = uv.fs_open(dest, "w", 438)
  if not dest_fd then
    error("无法创建目标文件: " .. dest)
  end
  uv.fs_write(dest_fd, result, 0)
  uv.fs_close(dest_fd)

  -- 创建脚本组件
  local script_src = get_popup_script_path(src_name)
  local script_src_fd = uv.fs_open(script_src, "r", 438)
  if not script_src_fd then
    error("无法打开源文件: " .. src)
  end

  local script_state = uv.fs_fstat(script_src_fd)
  local script_data = uv.fs_read(src_fd, script_state.size, 0)
  uv.fs_close(script_src_fd)

  local script_result = string.gsub(
    script_data,
    string.format("%sPopup", capitalize_words(src_name)),
    string.format("%sPopup", capitalize_words(dest_name))
  )
  script_result = string.gsub(
    script_result,
    string.format("%sPopup", src_name),
    string.format("%sPopup", dest_name)
  )
  local script_dest = string.format("%s/popup/%sPopup.ts", script_path, capitalize_words(dest_name))
  local script_dest_fd = uv.fs_open(script_dest, "w", 438)
  if not script_dest_fd then
    error("无法创建目标文件: " .. script_dest)
  end
  uv.fs_write(script_dest_fd, script_result, 0)
  uv.fs_close(script_dest_fd)

  -- 添加路径
  local path_fd = uv.fs_open(path_config_file, "r", 438)
  if not path_fd then
    error("无法打开路径配置文件: " .. path_config_file)
  end
  local path_state = uv.fs_fstat(path_fd)
  local path_data = uv.fs_read(path_fd, path_state.size, 0)
  uv.fs_close(path_fd)
  -- local start_idx, end_idx = string.find(path_data, get_popup_config_path(src_name))
  if string.find(path_data, get_popup_config_path(dest_name)) then
    vim.notify(string.format("already exists in path config file, create new popup: %s -> %s", src, dest))
    return
  end

  local path_result = string.gsub(
    path_data,
    get_popup_config_path(src_name) .. ',',
    get_popup_config_path(src_name) .. ',\n\t\t' .. get_popup_config_path(dest_name) .. ','
  )
  local path_write_fd = uv.fs_open(path_config_file, "w", 438)
  if not path_write_fd then
    error("无法写入路径配置文件: " .. path_config_file)
  end
  uv.fs_write(path_write_fd, path_result, 0)
  uv.fs_close(path_write_fd)

  vim.notify(string.format("create new popup: %s -> %s", src, dest))
end

function M.copy_popup()
  local popup_name = vim.fn.input('请输入新弹窗名称: ')
  if not popup_name or popup_name == "" then
    vim.notify("popup name is empty")
    return
  end

  M.create_new_popup("test", popup_name)
end

local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")

function M.remove_popup()
  builtin.find_files({
    prompt_title = "删除弹窗: ",
    find_command = { "fd", "--type", "d", "--max-depth", "1", "--hidden", "--exclude", ".git" },
    cwd = ui_path .. "/popup",
    attach_mappings = function(_, map)
      map('i', "<CR>", function(prompt_bufnr)
        local selection = actions_state.get_selected_entry()
        if selection then
          local popup_name = vim.fn.fnamemodify(selection.path, ":t")
          vim.notify(popup_name)
          uv.fs_unlink(selection.path)
        end
        actions.close(prompt_bufnr)
      end)
      return true
    end
  })
end

return M
