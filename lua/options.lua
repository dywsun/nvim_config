local options = {
  -- 鼠标与界面元素
  mouse = "", -- 禁用鼠标操作（防止鼠标点击改变光标位置）
  winbar = "%=%m %f ", -- 窗口顶部栏显示格式：%m 表示文件修改状态，%f 表示文件路径
  laststatus = 3, -- 全局状态栏（3 表示所有窗口共享同一个底部状态栏）
  showmode = false, -- 隐藏底部默认的模式显示（如 -- INSERT --），通常配合状态栏插件使用

  -- 窗口标题与光标
  title = true, -- 将当前编辑的文件名设置为终端的窗口标题
  cursorline = true, -- 高亮当前光标所在的行
  guicursor = "", -- 重置/使用默认的 GUI 光标形状设置

  -- 缩进与制表符 (Tab)
  expandtab = true, -- 将输入按下的 Tab 键自动转换为主位空格
  tabstop = 2, -- 1 个 Tab 字符在屏幕上占用的空格宽度
  shiftwidth = 2, -- 自动缩进或使用 >> / << 时缩进的空格数
  softtabstop = 2, -- 编辑模式下按 Tab 或 Backspace 时一次性插入/删除的空格数
  smartindent = true, -- 开启智能自动缩进（例如在 C/Java 语法的大括号后换行时自动缩进）

  -- 提示音与编码
  errorbells = false, -- 关闭报错时的提示音
  encoding = "utf-8", -- 设置内部使用编码为 UTF-8

  -- 排版与行号
  wrap = true, -- 开启自动折行（超长行自动换行显示，但不改变实际文本结构）
  number = true, -- 显示行号
  numberwidth = 4, -- 行号栏的固定占用列宽（至少 4 列宽）

  -- 搜索设置
  incsearch = true, -- 增量搜索：在输入搜索词的过程中实时高亮匹配内容
  ignorecase = true, -- 搜索时忽略大小写
  smartcase = true, -- 智能大小写：若搜索词全部小写则忽略大小写，一旦包含大写字母则精准匹配大小写
  hlsearch = true, -- 匹配到的搜索结果全部高亮显示

  -- 按键超时与文件撤销
  timeoutlen = 400, -- 快捷键组合按键的等待超时时间（单位：毫秒）
  swapfile = false, -- 关闭交换文件（.swp）的生成
  -- backup = false,   -- （已注释）不生成备份文件
  -- undodir = '~/.config/nvim/undodir', -- （已注释）撤销历史文件的存放路径
  undofile = true, -- 开启持久化撤销（关闭文件重新打开后，依然可以按 u 撤销历史修改）

  -- 侧边栏与滚动限制
  signcolumn = "yes", -- 始终显示左侧标记列（避免 Git/LSP 报错标记出现时界面左右跳动）
  colorcolumn = "80", -- 在第 80 列画一条垂直参考线，提醒代码不要写得太长
  scrolloff = 8, -- 光标上下移动时，距离顶部和底部始终保持至少 8 行的缓冲区

  -- 更新与性能
  updatetime = 30, -- 闲置多少毫秒后自动触发 CursorHold 事件并将数据写入磁盘（常供 GitSigns / LSP 等插件使用）

  -- 命令行与退格
  -- cmdheight = 2,     -- （已注释）设置底部命令行区域的高度为 2 行
  backspace = "indent,eol,start", -- 设置 Backspace 键可以删除自动缩进、换行符以及刚进入插入模式前的文本

  -- 颜色与折叠
  termguicolors = true, -- 开启 TrueColor（24 位真彩色）支持，让主题颜色更加丰富准确
  foldmethod = "syntax", -- 根据语法规则自动建立代码折叠
  foldlevelstart = 99, -- 打开文件时默认展开所有代码块（防止自动折叠影响阅读）
}

-- 遍历选项列表并应用到 vim.opt 中
for k, v in pairs(options) do
  vim.opt[k] = v
end

-- 在补全模式下隐藏某些无用的提示信息（如 "match 1 of 2"）
vim.opt.shortmess:append("c")

-- 透明背景设置示例（已注释）
-- vim.cmd [[ highlight Normal guibg=none ]]
