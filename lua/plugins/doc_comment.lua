-- ~/.config/nvim/lua/doc_comment.lua
-- 选中函数声明，按快捷键，在上方生成注解（基于 LuaSnip）
--   TypeScript / JavaScript -> JSDoc
--   C / C++                 -> Doxygen
--   Lua                     -> LuaLS (EmmyLua) 注解
--
-- 使用：init.lua 中加入  require("doc_comment").setup()
--       自定义快捷键     require("doc_comment").setup({ key = "<leader>jd" })

local M = {}

local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

---------------------------------------------------------------------------
-- 公共工具
---------------------------------------------------------------------------
local function trim(x)
  return (x:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- 按顶层逗号拆分（() [] {} <> 内的逗号不算）
local function split_params(str)
  local out, depth, cur, prev = {}, 0, "", ""
  for idx = 1, #str do
    local c = str:sub(idx, idx)
    if c:match("[%(%[{<]") then
      depth = depth + 1
    elseif c:match("[%)%]}>]") and prev ~= "=" and prev ~= "-" then -- "=>" "->" 不计
      depth = depth - 1
    end
    if c == "," and depth == 0 then
      out[#out + 1] = cur
      cur = ""
    else
      cur = cur .. c
    end
    prev = c
  end
  if cur:match("%S") then
    out[#out + 1] = cur
  end
  return out
end

-- 从 from 开始，找第一个 "(" 及与之配对的 ")"
local function match_paren(sig, from)
  local open = sig:find("%(", from or 1)
  if not open then
    return nil
  end
  local depth = 0
  for idx = open, #sig do
    local c = sig:sub(idx, idx)
    if c == "(" then
      depth = depth + 1
    elseif c == ")" then
      depth = depth - 1
      if depth == 0 then
        return open, idx
      end
    end
  end
  return nil
end

local function push(list, ...)
  for _, node in ipairs({ ... }) do
    list[#list + 1] = node
  end
end

---------------------------------------------------------------------------
-- TypeScript / JavaScript  ->  JSDoc
---------------------------------------------------------------------------
local ts = {}

function ts.parse(sig)
  local open, close = match_paren(sig)
  if not open then
    return nil
  end

  local params = {}
  for _, p in ipairs(split_params(sig:sub(open + 1, close - 1))) do
    local name = p:match("^%s*%.*([%w_$]+)")
    if name ~= "this" then -- 跳过 TS 的 this 伪参数
      params[#params + 1] = name or "options" -- 解构参数用占位名
    end
  end

  local rest = sig:sub(close + 1)
  local ret = rest:match("^%s*:%s*(.-)%s*[{=]") -- 有函数体 / 箭头函数
    or rest:match("^%s*:%s*(.-)%s*;?%s*$") -- 仅声明
  return { params = params, ret = ret }
end

function ts.build(info)
  local n = { t({ "/**", " * " }), i(1, "函数简要说明") }
  local idx = 2
  for _, name in ipairs(info.params) do
    push(n, t({ "", " * @param " .. name .. " " }), i(idx))
    idx = idx + 1
  end
  local ret = info.ret
  if ret and ret ~= "" and ret ~= "void" and ret ~= "Promise<void>" then
    push(n, t({ "", " * @returns " }), i(idx))
  end
  push(n, t({ "", " */" }))
  return s("", n)
end

---------------------------------------------------------------------------
-- C / C++  ->  Doxygen
---------------------------------------------------------------------------
local c = {}

local C_QUALIFIERS = {
  "static", "inline", "virtual", "extern", "constexpr", "consteval",
  "explicit", "friend", "_Noreturn", "__inline__", "__attribute__",
}

local function clean_c_type(ret)
  ret = ret:gsub("%[%[.-%]%]", "")
  for _, q in ipairs(C_QUALIFIERS) do
    ret = ret:gsub("%f[%w_]" .. q .. "%f[^%w_]", "")
  end
  return trim((ret:gsub("%s+", " ")))
end

function c.parse(sig)
  -- template<typename T, int N> 前缀
  local tparams = {}
  local tpl = sig:match("^%s*template%s*(%b<>)")
  if tpl then
    sig = sig:gsub("^%s*template%s*%b<>%s*", "")
    for _, p in ipairs(split_params(tpl:sub(2, -2))) do
      p = trim((p:gsub("%s*=.*$", "")))
      local name = p:match("([%w_]+)%s*$")
      if name then
        tparams[#tparams + 1] = name
      end
    end
  end

  -- operator() 里的括号不是参数列表
  local from = 1
  local _, op_end = sig:find("operator%s*%(%s*%)")
  if op_end then
    from = op_end + 1
  end
  local open, close = match_paren(sig, from)
  if not open then
    return nil
  end

  -- 函数名与返回类型
  local prefix = sig:sub(1, open - 1)
  local ret, name = prefix:match("^(.-)%s*(operator%s*[^%s%w_]+)%s*$")
  if not name then
    ret, name = prefix:match("^(.-)%s*([%w_~:]+)%s*$")
  end
  if not name then
    return nil
  end
  ret = clean_c_type(ret or "")

  -- 后置返回类型  auto f() -> int
  local trailing = sig:sub(close + 1):match("%->%s*([^{;]+)")
  if trailing then
    ret = trim(trailing)
  end

  -- 参数
  local params = {}
  for _, p in ipairs(split_params(sig:sub(open + 1, close - 1))) do
    p = trim((p:gsub("%s*=.*$", ""))) -- 去掉默认值
    if p == "..." then
      params[#params + 1] = "..."
    elseif p ~= "" and p ~= "void" then
      local pname = p:match("%(%s*[%*&%^]*%s*([%w_]+)%s*%)%s*%(") -- 函数指针
        or p:gsub("%b[]", ""):match("([%w_]+)%s*$") -- 普通参数 / 数组
      params[#params + 1] = pname or "arg"
    end
  end

  return { name = name, tparams = tparams, params = params, ret = ret }
end

function c.build(info)
  local n = { t({ "/**", " * @brief " }), i(1, "函数简要说明") }
  local idx = 2
  for _, name in ipairs(info.tparams) do
    push(n, t({ "", " * @tparam " .. name .. " " }), i(idx))
    idx = idx + 1
  end
  for _, name in ipairs(info.params) do
    push(n, t({ "", " * @param " .. name .. " " }), i(idx))
    idx = idx + 1
  end
  if info.ret ~= "" and info.ret ~= "void" then -- 构造/析构函数 ret 为空
    push(n, t({ "", " * @return " }), i(idx))
  end
  push(n, t({ "", " */" }))
  return s("", n)
end

---------------------------------------------------------------------------
-- Lua  ->  LuaLS 注解
---------------------------------------------------------------------------
local lua = {}

-- 从声明行开始向下扫描函数体，判断是否有带值的 return（忽略嵌套函数）
local function lua_returns(first)
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, -1, false)
  local stack, fdepth, found = {}, 0, false
  for _, line in ipairs(lines) do
    line = line:gsub("%-%-.*$", ""):gsub('"[^"]*"', '""'):gsub("'[^']*'", "''")
    for pos, w in line:gmatch("()([%a_][%w_]*)") do
      if w == "function" then
        stack[#stack + 1] = "f"
        fdepth = fdepth + 1
      elseif w == "if" or w == "do" or w == "repeat" then
        stack[#stack + 1] = "b"
      elseif w == "end" or w == "until" then
        if table.remove(stack) == "f" then
          fdepth = fdepth - 1
        end
        if #stack == 0 then
          return found
        end
      elseif w == "return" and fdepth == 1 then
        local rest = line:sub(pos + 6)
        if rest:match("^%s*[%w_{%(\"'%-#~%.]") and not rest:match("^%s*end%f[%W]") then
          found = true
        end
      end
    end
  end
  return found
end

function lua.parse(sig, ctx)
  if not sig:find("function") then
    return nil
  end
  local open, close = match_paren(sig)
  if not open then
    return nil
  end
  local params = {}
  for _, p in ipairs(split_params(sig:sub(open + 1, close - 1))) do
    p = trim(p)
    if p ~= "" then
      params[#params + 1] = p
    end
  end
  return { params = params, has_return = lua_returns(ctx.first) }
end

function lua.build(info)
  local n = { t("---"), i(1, "函数简要说明") }
  local idx = 2
  for _, name in ipairs(info.params) do
    push(n, t({ "", "---@param " .. name .. " " }), i(idx, "any"), t(" "), i(idx + 1))
    idx = idx + 2
  end
  if info.has_return then
    push(n, t({ "", "---@return " }), i(idx, "any"), t(" "), i(idx + 1))
  end
  return s("", n)
end

---------------------------------------------------------------------------
-- filetype -> 语言处理器
---------------------------------------------------------------------------
local LANGS = {
  typescript = ts, typescriptreact = ts, javascript = ts, javascriptreact = ts,
  c = c, cpp = c, cuda = c, objc = c,
  lua = lua,
}
M._LANGS = LANGS -- 便于测试

---------------------------------------------------------------------------
-- 主流程：读取选区 -> 解析 -> 在上方插入空行 -> 展开 snippet
---------------------------------------------------------------------------
function M.generate()
  local lang = LANGS[vim.bo.filetype]
  if not lang then
    vim.notify("doc_comment: 不支持的文件类型 " .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end

  -- 先取选区行号（必须在退出 visual 模式之前）
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  local first, last = math.min(a, b), math.max(a, b)
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)

  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local info = lang.parse(table.concat(lines, " "), { first = first })
  if not info then
    vim.notify("doc_comment: 未在选中内容中找到函数声明", vim.log.levels.WARN)
    return
  end

  local indent = lines[1]:match("^%s*") or ""
  vim.api.nvim_buf_set_lines(0, first - 1, first - 1, false, { indent })
  vim.api.nvim_win_set_cursor(0, { first, #indent })
  vim.cmd("startinsert!")
  vim.schedule(function()
    ls.snip_expand(lang.build(info))
  end)
end

function M.setup(opts)
  opts = opts or {}
  local key = opts.key or "<leader>jd"
  vim.api.nvim_create_autocmd("FileType", {
    pattern = vim.tbl_keys(LANGS),
    callback = function(ev)
      vim.keymap.set("v", key, M.generate, { buffer = ev.buf, desc = "生成函数注解" })
    end,
  })
end

return M

--[[
别忘了配置 LuaSnip 的跳转键，例如：

  local ls = require("luasnip")
  vim.keymap.set({ "i", "s" }, "<Tab>", function()
    if ls.jumpable(1) then ls.jump(1) else
      vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "n", false)
    end
  end)
  vim.keymap.set({ "i", "s" }, "<S-Tab>", function() ls.jump(-1) end)
]]

