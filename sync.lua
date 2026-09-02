#!/usr/bin/env lua
--=============================================================================
-- 脚本名称: sync.lua
-- 功能描述: 跨平台 Neovim 配置同步与变更预览工具
--
-- 使用方法:
--   在你的 nvim-config 仓库根目录下执行:
--   nvim -l sync.lua
--
-- 核心特性:
--   1. 绝对跨平台: 动态解析操作系统的 `stdpath("config")`，兼容 Win/Mac/Linux。
--   2. 零外部依赖: 完全基于 Neovim 内置的 `vim.uv` (libuv) API 进行文件系统操作。
--   3. 精准差异预览: 调用底层 `vim.diff` 算法，生成带行号和统计的彩色 Hunk 视图。
--   4. 安全交互: 同步覆盖前强制进行 Y/N 确认，防止误操作破坏本地仓库。
--=============================================================================

local uv = vim.uv or vim.loop

-- 替换被 nvim 拦截的默认 print，直接向终端写入原始字节流以保证颜色正常渲染
local function print(...)
  local args = { ... }
  for i, v in ipairs(args) do
    io.stdout:write(tostring(v))
    if i < #args then io.stdout:write("\t") end
  end
  io.stdout:write("\n")
  io.stdout:flush()
end

-- 快速计算文本总行数
local function get_line_count(str)
  if not str or str == "" then return 0 end
  local _, count = str:gsub("\n", "\n")
  if str:sub(-1) ~= "\n" then count = count + 1 end
  return count
end

-- ANSI 颜色代码
local C = {
  reset = "\27[0m",
  green = "\27[32m",
  red = "\27[31m",
  yellow = "\27[33m",
  cyan = "\27[36m",
  bold = "\27[1m",
}

-- 1. 路径配置
local source_dir = vim.fn.stdpath("config")
if type(source_dir) == "string" then
  source_dir = source_dir:gsub("\\", "/") -- 统一规范化为正斜杠，兼容 Windows
end
local target_dir = uv.cwd():gsub("\\", "/")

print(
  string.format("%s源目录 (生产环境):%s %s", C.cyan, C.reset, source_dir)
)
print(
  string.format(
    "%s目标目录 (Git 仓库):%s %s",
    C.cyan,
    C.reset,
    target_dir
  )
)

-- 2. 递归扫描目录并读取文件内容
local function get_files(dir, prefix, acc)
  acc = acc or {}
  prefix = prefix or ""
  local handle = uv.fs_scandir(dir)
  if not handle then return acc end

  while true do
    local name, t = uv.fs_scandir_next(handle)
    if not name then break end

    -- 排除 git 仓库相关文件和脚本自身
    if name ~= ".git" and name ~= "sync.lua" then
      local rel_path = prefix == "" and name or (prefix .. "/" .. name)
      local full_path = dir .. "/" .. name

      if
        t == "directory"
        or (
          not t
          and uv.fs_stat(full_path)
          and uv.fs_stat(full_path).type == "directory"
        )
      then
        get_files(full_path, rel_path, acc)
      else
        local fd = io.open(full_path, "rb")
        if fd then
          acc[rel_path] = fd:read("*a")
          fd:close()
        end
      end
    end
  end
  return acc
end

local src_files = get_files(source_dir)
local tgt_files = get_files(target_dir)

-- 3. 对比变更
local changes = { added = {}, modified = {}, deleted = {} }

for path, content in pairs(src_files) do
  if not tgt_files[path] then
    table.insert(changes.added, path)
  elseif tgt_files[path] ~= content then
    table.insert(changes.modified, path)
  end
end

for path in pairs(tgt_files) do
  if not src_files[path] then table.insert(changes.deleted, path) end
end

-- 4. 打印详细变更预览（带颜色与行号）
print(
  string.format(
    "\n%s-------------------- 变更预览 --------------------%s",
    C.bold,
    C.reset
  )
)
if #changes.added == 0 and #changes.modified == 0 and #changes.deleted == 0 then
  print(
    string.format(
      "%s没有发现任何变更，配置已是最新。%s",
      C.green,
      C.reset
    )
  )
  os.exit(0)
end

for _, p in ipairs(changes.added) do
  local lines = get_line_count(src_files[p])
  print(
    string.format(" %s[+] 新增: %s (%d 行)%s", C.green, p, lines, C.reset)
  )
end

for _, p in ipairs(changes.deleted) do
  local lines = get_line_count(tgt_files[p])
  print(string.format(" %s[-] 删除: %s (%d 行)%s", C.red, p, lines, C.reset))
end

for _, p in ipairs(changes.modified) do
  print(string.format(" %s[~] 修改: %s%s", C.yellow, p, C.reset))
  print(string.format("     --- 文件: %s ---", p))

  local old_text = tgt_files[p] or ""
  local new_text = src_files[p] or ""

  local old_lines = vim.split(old_text, "\n")
  local new_lines = vim.split(new_text, "\n")

  -- 利用 Neovim 内置 Diff 获取索引数据块
  local hunks = vim.diff(old_text, new_text, { result_type = "indices" })

  for _, hunk in ipairs(hunks) do
    local start_a, count_a, start_b, count_b =
      hunk[1], hunk[2], hunk[3], hunk[4]

    -- 打印 Diff 块头信息
    print(
      string.format(
        "     %s@@ -%d,%d +%d,%d @@%s",
        C.cyan,
        start_a,
        count_a,
        start_b,
        count_b,
        C.reset
      )
    )

    -- 打印被删除或修改的旧行 (红色)
    for i = start_a, start_a + count_a - 1 do
      if old_lines[i] then
        print(
          string.format(
            "       %s%4d | - %s%s",
            C.red,
            i,
            old_lines[i],
            C.reset
          )
        )
      end
    end

    -- 打印被添加或修改的新行 (绿色)
    for i = start_b, start_b + count_b - 1 do
      if new_lines[i] then
        print(
          string.format(
            "       %s%4d | + %s%s",
            C.green,
            i,
            new_lines[i],
            C.reset
          )
        )
      end
    end
  end
  print("     ---------------------------------------------")
end
print(
  string.format(
    "%s--------------------------------------------------%s\n",
    C.bold,
    C.reset
  )
)

-- 5. 交互确认
io.stdout:write(
  string.format(
    "%s确认将以上变更同步覆盖到当前 Git 仓库吗？(y/N): %s",
    C.bold,
    C.reset
  )
)
io.stdout:flush()
local input = io.read()

if input and (input:lower() == "y" or input:lower() == "yes") then
  local function ensure_dir(path)
    local parts = {}
    for p in path:gmatch("[^/]+") do
      table.insert(parts, p)
    end
    local curr = ""
    for i = 1, #parts - 1 do
      curr = curr == "" and parts[i] or (curr .. "/" .. parts[i])
      uv.fs_mkdir(target_dir .. "/" .. curr, 511)
    end
  end

  local function write_file(from, to)
    local fin = io.open(from, "rb")
    local fout = io.open(to, "wb")
    if fin and fout then
      fout:write(fin:read("*a"))
      fin:close()
      fout:close()
    end
  end

  for _, p in ipairs(changes.added) do
    ensure_dir(p)
    write_file(source_dir .. "/" .. p, target_dir .. "/" .. p)
  end
  for _, p in ipairs(changes.modified) do
    ensure_dir(p)
    write_file(source_dir .. "/" .. p, target_dir .. "/" .. p)
  end

  print(
    string.format(
      "\n%s[成功] 同步完成！你现在可以通过 git diff 或 git status 查看并提交更改了。%s",
      C.green,
      C.reset
    )
  )
else
  print(
    string.format("\n%s[已取消] 未做任何修改。%s", C.yellow, C.reset)
  )
end
