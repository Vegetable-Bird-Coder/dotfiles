vim.env.PATH = "/opt/homebrew/bin:/usr/local/bin:" .. vim.env.PATH

-- =======================================================================
-- [1] 基础设置 (Options)
-- =======================================================================

-- Leader 键（空格）
vim.g.mapleader = ' '

local opt = vim.opt

-- 编辑
opt.autowrite       = true                    -- 切换文件时自动保存
opt.clipboard       = 'unnamedplus'           -- 复制内容同步到系统剪贴板
opt.expandtab       = true                    -- Tab 键输入空格而非制表符
opt.shiftwidth      = 2                       -- 自动缩进宽度 2 空格
opt.softtabstop     = 2                       -- Tab 键按下时插入 2 空格
opt.tabstop         = 2                       -- 一个 Tab 显示为 2 空格宽

-- 显示
opt.number          = true                    -- 显示行号
opt.relativenumber  = true                    -- 相对行号（方便用 5j/10k 跳转）
opt.scrolloff       = 8                       -- 光标距顶部/底部保留 8 行，避免贴边
opt.signcolumn      = 'yes'                   -- 固定显示 sign 列（git 标记、诊断图标）
opt.termguicolors   = true                    -- 启用 24 位真彩色（主题需要）
opt.wrap            = false                   -- 长行不折行，水平滚动查看

-- 搜索
opt.ignorecase      = true                    -- 搜索时忽略大小写
opt.smartcase       = true                    -- 搜索含大写字母时自动区分大小写

-- 命令行
opt.wildmode        = 'longest:full,full'     -- Tab 先补全最长公共前缀，再按 Tab 弹出完整列表
opt.wildignorecase  = true                    -- 命令行补全忽略大小写

-- 窗口
opt.splitbelow      = true                    -- 水平分屏在下方打开
opt.splitright      = true                    -- 垂直分屏在右侧打开

-- 其他
opt.mouse           = 'a'                     -- 所有模式下启用鼠标

-- =======================================================================
-- [2] 插件管理 (Lazy.nvim)
-- =======================================================================

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- 主题
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- 文件树
  { 'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' } },

  -- 顶部标签栏
  { 'akinsho/bufferline.nvim', version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons' },

  -- 模糊搜索
  { 'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' } },

  -- 代码补全（blink.cmp，替代 nvim-cmp）
  { 'saghen/blink.cmp',
    version = '1.*',                           -- 锁定 v1 稳定版
    opts = {
      keymap = {
        preset = 'none',
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-Space>'] = { 'show', 'fallback' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },
      completion = { documentation = { auto_show = true } },
      sources = {
        default = { 'lsp', 'snippets', 'path', 'buffer' },
      },
      cmdline = { enabled = true },
      signature = { enabled = true },
    },
  },

  -- LSP 服务器安装（mason 仅负责安装，配置用 Neovim 原生 API）
  { 'williamboman/mason.nvim' },

  -- 语法高亮 + 代码结构
  { 'nvim-treesitter/nvim-treesitter', branch = 'main', build = ':TSUpdate' },
  { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' } },

  -- Git
  { 'lewis6991/gitsigns.nvim' },             -- 行号旁显示增/改/删状态
  { 'sindrets/diffview.nvim',                -- 并排对比和文件历史
    dependencies = { 'nvim-lua/plenary.nvim' } },

  -- 编辑增强
  { 'windwp/nvim-autopairs' },               -- 输入 ( 自动补 )

  -- Lua 开发辅助（让 lua_ls 正确识别 vim API）
  { 'folke/lazydev.nvim', ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
})

-- =======================================================================
-- [3] 插件配置 (Plugin Setup)
-- =======================================================================

-- 主题：Catppuccin Latte 浅色变体，与 Ghostty 统一
vim.cmd.colorscheme "catppuccin-latte"

-- 文件树
require('nvim-tree').setup({
  sync_root_with_cwd = true,               -- :cd 时文件树自动跟随切换根目录
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')
    api.map.on_attach.default(bufnr)              -- 保留默认键位
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set('n', 'J', '5j', opts)          -- Shift+j 跳 5 行
    vim.keymap.set('n', 'K', '5k', opts)          -- Shift+k 跳 5 行
  end,
  view = {
    width = 28,                        -- 文件树宽度
    relativenumber = false,            -- 文件树内不显示相对行号
  },
  renderer = {
    group_empty = true,                -- 空文件夹合并显示（a/b/c 而非嵌套）
    icons = {
      git_placement = "after",         -- git 图标显示在文件名后面
      glyphs = {
        git = {
          unstaged  = "●",             -- 已修改未暂存
          staged    = "✔",             -- 已暂存
          unmerged  = "",              -- 合并冲突
          renamed   = "➜",            -- 重命名
          untracked = "◆",             -- 未跟踪
          deleted   = "✖",             -- 已删除
          ignored   = "◌",             -- 被 .gitignore 忽略
        },
      },
    },
  },
  filters = {
    dotfiles = false,                  -- false = 不过滤隐藏文件（即显示 dotfiles）
    git_ignored = false,               -- false = 不过滤 .gitignore 忽略的文件（即显示它们）
  },
  git = {
    enable = true,                     -- 启用 git 状态显示
    show_on_dirs = true,               -- 文件夹也显示 git 状态
  },
  update_focused_file = {
    enable = true,                     -- 打开文件时自动定位到文件树对应位置
  },
})

-- 顶部标签栏：文件树打开时自动留出空间，不会重叠
require("bufferline").setup({
  options = {
    offsets = {
      {
        filetype = "NvimTree",         -- 检测到 NvimTree 窗口时
        text = "File Explorer",        -- 空出区域显示的标题
        highlight = "Directory",       -- 标题高亮样式
        text_align = "left",           -- 标题左对齐
        separator = true               -- 标签栏和文件树之间显示分隔线
      }
    }
  }
})

-- 代码补全：blink.cmp（配置在 lazy spec 的 opts 中，无需额外 setup）
local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Mason（仅负责安装 LSP 服务器）
require('mason').setup()

-- LSP 服务器配置（Neovim 0.12+ 原生 API）
-- '*' 表示所有 LSP 服务器的通用配置
vim.lsp.config('*', {
  capabilities = capabilities,             -- 告诉服务器客户端支持哪些功能（补全、跳转等）
})

-- Go 语言服务器（gopls）特殊配置
vim.lsp.config('gopls', {
  settings = {
    gopls = {
      analyses = { unusedparams = true },  -- 检查未使用的函数参数
      staticcheck = true,                  -- 启用额外的静态检查
      gofumpt = true,                      -- 使用 gofumpt 格式化（比 gofmt 更严格）
    },
  },
})

-- Lua 语言服务器（lua_ls）特殊配置
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },   -- Neovim 使用 LuaJIT 运行时
      telemetry = { enable = false },      -- 关闭遥测数据上报
    },
  },
})

-- 启用所有 LSP 服务器（pyright 和 clangd 用默认配置即可，无需单独配置）
vim.lsp.enable({ 'lua_ls', 'pyright', 'gopls', 'clangd' })

-- Treesitter（语法解析器安装）
require('nvim-treesitter').install({ "go", "lua", "python", "cpp" })

-- Textobjects：让 vim 理解代码结构（函数、类、参数），从而可以快捷键选中/跳转
-- 例如：光标在函数内，按 vaf 可选中整个函数，按 ]f 可跳到下一个函数
require('nvim-treesitter-textobjects').setup({
  select = { lookahead = true },       -- 选择时自动向前查找最近的文本对象
  move = { set_jumps = true },         -- 跳转时记录位置，可用 Ctrl+o 跳回
})

-- 编辑增强
require('nvim-autopairs').setup()      -- 输入左括号自动补右括号

-- Git
require('gitsigns').setup()            -- 行号旁显示 git 增/改/删状态
require('diffview').setup()            -- :DiffviewOpen 并排对比

-- =======================================================================
-- [4] 快捷键设置 (Keymaps)
-- =======================================================================

-- ── 基础操作 ──
vim.keymap.set('i', 'jj', '<Esc>', { noremap = true, silent = true, desc = '退出插入模式' })
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = '保存' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = '退出' })

-- ── 文件树 ──
vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>', { desc = '打开/关闭文件树' })
vim.keymap.set('n', '<leader>=', ':NvimTreeResize +5<CR>', { silent = true, desc = '加宽文件树' })
vim.keymap.set('n', '<leader>-', ':NvimTreeResize -5<CR>', { silent = true, desc = '收窄文件树' })

-- ── 窗口与 Buffer ──
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = '切到左窗口' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = '切到下窗口' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = '切到上窗口' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = '切到右窗口' })
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { silent = true, desc = '下一个 buffer' })
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { silent = true, desc = '上一个 buffer' })
vim.keymap.set('n', '<leader>c', function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo.filetype ~= "NvimTree" then
    vim.cmd('bprevious')
    vim.cmd('bdelete ' .. buf)
  end
end, { silent = true, desc = '关闭当前 buffer（保持窗口布局）' })

-- ── 搜索（Telescope） ──
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = '按文件名搜索' })
vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = '搜索文件内容' })
vim.keymap.set('n', '<leader>fb', telescope.buffers, { desc = '搜索已打开的 buffer' })
vim.keymap.set('n', '<leader>fh', telescope.help_tags, { desc = '搜索帮助文档' })

-- ── LSP 跳转与操作 ──
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, noremap = true, silent = true, desc = desc })
    end
    -- 跳转
    map('n', 'gd', vim.lsp.buf.definition, '跳转到定义')
    map('n', 'gD', vim.lsp.buf.declaration, '跳转到声明')
    map('n', 'gr', vim.lsp.buf.references, '查找引用')
    map('n', 'gt', vim.lsp.buf.type_definition, '类型定义')
    -- 操作
    map('n', '<leader>i', vim.lsp.buf.hover, '悬停信息')
    map('n', '<leader>rn', vim.lsp.buf.rename, '重命名')
    map('n', '<leader>ca', vim.lsp.buf.code_action, '代码动作')
    map('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, '格式化')
    -- 诊断
    map('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, '上一个诊断')
    map('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, '下一个诊断')
    map('n', '<leader>e', vim.diagnostic.open_float, '显示诊断详情')
    map('n', '<leader>dl', vim.diagnostic.setloclist, '诊断列表')
  end,
})

-- ── 代码结构（Textobjects） ──
-- 文本对象选择：vaf = 选中整个函数，dif = 删除函数体，yac = 复制整个类
local ts_select = require('nvim-treesitter-textobjects.select')
vim.keymap.set({ 'x', 'o' }, 'af', function() ts_select.select_textobject('@function.outer', 'textobjects') end, { desc = '选择整个函数' })
vim.keymap.set({ 'x', 'o' }, 'if', function() ts_select.select_textobject('@function.inner', 'textobjects') end, { desc = '选择函数内部' })
vim.keymap.set({ 'x', 'o' }, 'ac', function() ts_select.select_textobject('@class.outer', 'textobjects') end, { desc = '选择整个类' })
vim.keymap.set({ 'x', 'o' }, 'ic', function() ts_select.select_textobject('@class.inner', 'textobjects') end, { desc = '选择类内部' })
vim.keymap.set({ 'x', 'o' }, 'aa', function() ts_select.select_textobject('@parameter.outer', 'textobjects') end, { desc = '选择参数' })
vim.keymap.set({ 'x', 'o' }, 'ia', function() ts_select.select_textobject('@parameter.inner', 'textobjects') end, { desc = '选择参数内部' })
vim.keymap.set({ 'x', 'o' }, 'ab', function() ts_select.select_textobject('@block.outer', 'textobjects') end, { desc = '选择代码块' })
vim.keymap.set({ 'x', 'o' }, 'ib', function() ts_select.select_textobject('@block.inner', 'textobjects') end, { desc = '选择代码块内部' })

-- 函数/类跳转：]f = 下一个函数，[c = 上一个类
local ts_move = require('nvim-treesitter-textobjects.move')
vim.keymap.set({ 'n', 'x', 'o' }, ']f', function() ts_move.goto_next_start('@function.outer', 'textobjects') end, { desc = '下一个函数开始' })
vim.keymap.set({ 'n', 'x', 'o' }, ']F', function() ts_move.goto_next_end('@function.outer', 'textobjects') end, { desc = '下一个函数结束' })
vim.keymap.set({ 'n', 'x', 'o' }, '[f', function() ts_move.goto_previous_start('@function.outer', 'textobjects') end, { desc = '上一个函数开始' })
vim.keymap.set({ 'n', 'x', 'o' }, '[F', function() ts_move.goto_previous_end('@function.outer', 'textobjects') end, { desc = '上一个函数结束' })
vim.keymap.set({ 'n', 'x', 'o' }, ']c', function() ts_move.goto_next_start('@class.outer', 'textobjects') end, { desc = '下一个类开始' })
vim.keymap.set({ 'n', 'x', 'o' }, ']C', function() ts_move.goto_next_end('@class.outer', 'textobjects') end, { desc = '下一个类结束' })
vim.keymap.set({ 'n', 'x', 'o' }, '[c', function() ts_move.goto_previous_start('@class.outer', 'textobjects') end, { desc = '上一个类开始' })
vim.keymap.set({ 'n', 'x', 'o' }, '[C', function() ts_move.goto_previous_end('@class.outer', 'textobjects') end, { desc = '上一个类结束' })

-- ── Git ──
vim.keymap.set('n', '<leader>dd', ':DiffviewOpen<CR>', { silent = true, desc = '打开 diff 视图' })
vim.keymap.set('n', '<leader>dh', ':DiffviewFileHistory %<CR>', { silent = true, desc = '当前文件 git 历史' })
vim.keymap.set('n', '<leader>da', ':DiffviewFileHistory<CR>', { silent = true, desc = '全部 git 历史' })
vim.keymap.set('n', '<leader>dc', ':DiffviewClose<CR>', { silent = true, desc = '关闭 diff 视图' })

-- ── 编辑增强 ──
vim.keymap.set('n', 'J', '5j', { desc = '向下移动 5 行' })
vim.keymap.set('n', 'K', '5k', { desc = '向上移动 5 行' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = '选中行下移' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = '选中行上移' })
vim.keymap.set('v', '<', '<gv', { desc = '左缩进并保持选中' })
vim.keymap.set('v', '>', '>gv', { desc = '右缩进并保持选中' })
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>', { silent = true, desc = '清除搜索高亮' })

-- =======================================================================
-- [5] 自动命令 (Autocommands)
-- =======================================================================

-- 自动切输入法到英文 (仅 macOS)
if vim.fn.has("mac") == 1 then
  vim.api.nvim_create_autocmd({"VimEnter", "InsertLeave", "WinEnter", "BufEnter", "FocusGained"}, {
    callback = function()
      vim.fn.system("im-select com.apple.keylayout.US")
    end,
  })
end

-- 复制时短暂高亮被复制的文本
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})

-- 自动启用 Treesitter 语法高亮（Neovim 0.12+ 内置）
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- 自动保存和恢复折叠状态
vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "*.*",
  command = "mkview",
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*.*",
  command = "silent! loadview",
})

-- 进入终端时自动进入插入模式，隐藏行号
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})
