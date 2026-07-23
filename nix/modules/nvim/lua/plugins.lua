local utils = require('utils')
local options = require('options')
local safe_require = utils.safe_require

-- [테마 설정: Catppuccin]
safe_require('catppuccin', function(cat)
  cat.setup({
    flavour = "macchiato", -- latte, frappe, macchiato, mocha
    transparent_background = false,
  })
  vim.cmd.colorscheme("catppuccin")
end)

-- [투명 배경 및 렌더링 최적화]
-- 로컬 환경(is_transparent = true)일 때 배경색을 완전히 제거하여 
-- GPU 터미널(Ghostty)에서의 렌더링 잔상(검은 블록)을 방지합니다.
if options.is_transparent then
  local function clear_bg()
    local groups = {
      "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer",
      "MsgArea", "ModeMsg", "MsgSeparator", "SpellBad", "SpellCap",
      "SpellLocal", "SpellRare", "Folded", "FoldColumn", "Conceal"
    }
    for _, group in ipairs(groups) do
      pcall(vim.api.nvim_set_hl, 0, group, { bg = "NONE", ctermbg = "NONE" })
    end
  end
  
  clear_bg()
  -- 테마가 바뀔 때마다 다시 적용
  vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_bg })
end

-- [기본 UI 컴포넌트]
safe_require("lualine", function(lualine)
  local lualine_theme = 'ayu_dark'
  if utils.is_remote then lualine_theme = 'ayu_mirage' end
  lualine.setup { options = { theme = lualine_theme } }
end)
safe_require("bufferline", function(bufferline) bufferline.setup{} end)
safe_require("gitsigns", function(gitsigns) gitsigns.setup() end)
safe_require("ibl", function(ibl)
  local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
  }

  local hooks = require("ibl.hooks")
  hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#F07178" })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#FFCC66" })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#59C2FF" })
    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#FFB454" })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#C2D94C" })
    vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#D4BFFF" })
    vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#95E6CB" })
  end)

  ibl.setup({
    indent = { char = "│", highlight = highlight },
    scope = { enabled = false }, -- hlchunk와 겹치지 않게 scope는 끕니다.
  })
end)

safe_require("rainbow-delimiters", function(rd)
  -- rainbow-delimiters는 기본적으로 위에서 설정한 RainbowRed 등의 하이라이트 그룹을 사용하도록 연동될 수 있습니다.
end)

safe_require("hlchunk", function(hlchunk)
  hlchunk.setup({
    chunk = {
      enable = true,
      use_treesitter = true,
      style = {
        { fg = "#ffcc66" }, -- 현재 블록의 강조 색상
        { fg = "#c34043" }, -- 오류 등이 있을 때의 색상
      },
    },
    indent = {
      enable = true,
      use_treesitter = true,
    },
  })
end)
safe_require("Comment", function(comment) comment.setup() end)
safe_require("nvim-autopairs", function(autopairs) autopairs.setup() end)
safe_require("mini.icons", function(icons) icons.setup(); icons.mock_nvim_web_devicons() end)

-- [파일 탐색기 & 관리]
safe_require("oil", function(oil)
  oil.setup()
  vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
end)

safe_require("neo-tree", function(neotree)
  neotree.setup({
    close_if_last_window = true,
    filesystem = { follow_current_file = { enabled = true }, use_libuv_file_watcher = true },
    window = { width = 30, mappings = { ["<space>"] = "none" } }
  })
  vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { silent = true })
end)

-- [검색 & 유틸리티]
safe_require("telescope.builtin", function(builtin)
  vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Find files" })
  vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = "Live grep" })
  vim.keymap.set('n', '<leader>s', builtin.lsp_document_symbols, { desc = "Outline" })
  vim.keymap.set('n', '<leader>d', builtin.lsp_definitions, { desc = "Definition" })
  vim.keymap.set('n', '<leader>r', builtin.lsp_references, { desc = "References" })
end)

safe_require("toggleterm", function(toggleterm)
  toggleterm.setup({ open_mapping = [[<C-/>]], direction = 'float', float_opts = { border = 'curved' } })
  vim.keymap.set({'n', 't'}, '<C-/>', '<cmd>ToggleTerm<cr>')
  vim.keymap.set({'n', 't'}, '<C-_>', '<cmd>ToggleTerm<cr>')
end)

safe_require("trouble", function(trouble)
  trouble.setup({})
  vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>")
end)

safe_require("lazygit", function(lazygit)
  vim.keymap.set("n", "<leader>G", "<cmd>LazyGit<cr>", { desc = "LazyGit"})
end)

safe_require("neogit", function(neogit)
  neogit.setup({
    integrations = {
      diffview = true,
    },
  })
  vim.keymap.set("n", "<leader>ng", "<cmd>Neogit<cr>", { desc = "Neogit" })
end)

safe_require("diffview", function(diffview)
  diffview.setup({})
  vim.keymap.set("n", "<leader>dv", "<cmd>DiffviewOpen<cr>", { desc = "Diffview Open" })
  vim.keymap.set("n", "<leader>dc", "<cmd>DiffviewClose<cr>", { desc = "Diffview Close" })
  -- Compatibility Keymaps
  vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diffview Open (Legacy)" })
  vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Diffview Close (Legacy)" })
end)

safe_require("git-conflict", function(git_conflict)
  git_conflict.setup()
end)

-- [Obsidian 설정]
safe_require("obsidian", function(obsidian)
  local vault_path = vim.fn.expand("~/Documents/obsidian_personal_note")
  if vim.fn.isdirectory(vault_path) == 1 then
    obsidian.setup({
      workspaces = { { name = "notes", path = vault_path } },
      ui = { enable = true, concealcursor = "nv" },
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
        ["v"] = { char = "", hl_group = "ObsidianCheck" },
      },
      legacy_commands = false,
    })
  end
  vim.keymap.set("n", "<leader>on", "<cmd>Obsidian new<cr>")
  vim.keymap.set("n", "<leader>os", "<cmd>Obsidian search<cr>")
end)

-- [LSP & 자동완성]
local cmp_ok, cmp = pcall(require, "cmp")
if cmp_ok then
  cmp.setup({
    snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'luasnip' } }, { { name = 'buffer' }, { name = 'path' } })
  })
end

safe_require("luasnip", function(luasnip)
  luasnip.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    delete_check_events = "TextChanged",
  })
  require("luasnip.loaders.from_vscode").lazy_load()
end)

-- Treesitter Config
safe_require("nvim-treesitter", function(ts)
  ts.setup()
end)

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if lang then
      pcall(vim.treesitter.start, args.buf, lang)
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- [Container/Distrobox 하이브리드 지원 로직]
vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = { "/opt/*", "/usr/include/*" },
  callback = function(args)
    local file = args.file
    if vim.fn.filereadable(file) == 1 then return end

    local container = vim.env.DISTROBOX_NAME or "ros2-jazzy"
    local cmd = string.format("distrobox enter %s -- cat '%s'", container, file)
    local content = vim.fn.systemlist(cmd)
    if vim.v.shell_error == 0 then
      vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, content)
      vim.api.nvim_set_option_value("readonly", true, { buf = args.buf })
      vim.api.nvim_set_option_value("buftype", "nowrite", { buf = args.buf })
      local ft = vim.filetype.match({ filename = file })
      if ft then vim.api.nvim_set_option_value("filetype", ft, { buf = args.buf }) end
    end
  end,
})

-- [LSP Config (Neovim 0.11+ Modern Way)]
local capabilities = {}
local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_lsp_ok then capabilities = cmp_nvim_lsp.default_capabilities() end

local servers = { 'gopls', 'nil_ls', 'pyright', 'bashls', 'yamlls', 'taplo', 'jsonls', 'cmake', 'autotools_ls' }

local function get_server_opts(name)
  local opts = { capabilities = capabilities }
  if name == "yamlls" then
    opts.cmd = { "yaml-language-server", "--stdio" }
    opts.filetypes = { "yaml", "yaml.gitlab" }
    opts.root_dir = vim.fs.root(0, { ".git", ".gitlab-ci.yml" })
    opts.settings = {
      yaml = {
        schemaStore = {
          enable = true, -- Enable SchemaStore for general schemas just in case
        },
        schemas = {
          kubernetes = { "k8s/**/*.yaml", "k8s/**/*.yml", "*k8s*.yaml", "*k8s*.yml" },
          ["file:///home/nxtp-sj/.config/nvim/gitlab-ci.json"] = { "*gitlab-ci*.yml", ".gitlab-ci.yml" },
        },
      },
    }
  end
  return opts
end

if vim.lsp.config then
  for _, lsp in ipairs(servers) do
    local name = lsp
    pcall(function()
      vim.lsp.config(name, get_server_opts(name))
      local cfg = vim.lsp.config[name]
      if cfg and cfg.cmd and type(cfg.cmd) == "table" and cfg.cmd[1] then
        if vim.fn.executable(cfg.cmd[1]) == 1 then
          vim.lsp.enable(name)
        end
      else
        vim.lsp.enable(name)
      end
    end)
  end
end

-- [LSP 단어 하이라이트 및 키매핑 설정]
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local opts = { buffer = event.buf }

    -- [LSP 키매핑]
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = event.buf, desc = "Go to Definition" })
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = event.buf, desc = "Go to References" })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = event.buf, desc = "Hover Documentation" })
    vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, { buffer = event.buf, desc = "Go to Definition (Tags style)" })
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = event.buf, desc = "Rename Symbol" })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf, desc = "Code Action" })

    -- [단어 하이라이트 설정]
    if client and client:supports_method('textDocument/documentHighlight') then
      local group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

local function set_lsp_highlights()
  vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#3d424d", underline = true, sp = "#ffcc66" })
  vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#3d424d", underline = true, sp = "#ffcc66" })
  vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#3d424d", underline = true, bold = true, sp = "#ffcc66" })
end

set_lsp_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_lsp_highlights })

-- [Diagnostic 하이라이트 설정]
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { underline = false, strikethrough = true, sp = "Red" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { underline = false, strikethrough = true, sp = "Yellow" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { underline = false, strikethrough = true, sp = "LightBlue" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { underline = false, strikethrough = true, sp = "LightGrey" })

-- [Markdown Rendering]
-- 完全复原 markview.nvim 官方 GitHub 的极简高级感配色 (Catppuccin Macchiato 色系)
local function set_markview_highlights()
  -- 清除任何可能干扰的丑陋全宽背景
  vim.api.nvim_set_hl(0, "MarkviewPalette0Bg", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "MarkviewPalette1Bg", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "MarkviewPalette2Bg", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "MarkviewPalette3Bg", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "MarkviewPalette4Bg", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "MarkviewPalette5Bg", { bg = "NONE" })

  -- Github 截图里的鲜艳边框和文字颜色 (Catppuccin Macchiato)
  vim.api.nvim_set_hl(0, "MarkviewPalette0Sign", { fg = "#cad3f5" }) -- Text
  vim.api.nvim_set_hl(0, "MarkviewPalette1Sign", { fg = "#ed8796" }) -- Red
  vim.api.nvim_set_hl(0, "MarkviewPalette2Sign", { fg = "#eed49f" }) -- Yellow
  vim.api.nvim_set_hl(0, "MarkviewPalette3Sign", { fg = "#c6a0f6" }) -- Mauve
  vim.api.nvim_set_hl(0, "MarkviewPalette4Sign", { fg = "#a6da95" }) -- Green (Tip)
  vim.api.nvim_set_hl(0, "MarkviewPalette5Sign", { fg = "#8aadf4" }) -- Blue (Note)
  
  vim.api.nvim_set_hl(0, "MarkviewPalette0Fg", { fg = "#cad3f5" })
  vim.api.nvim_set_hl(0, "MarkviewPalette1Fg", { fg = "#ed8796" })
  vim.api.nvim_set_hl(0, "MarkviewPalette2Fg", { fg = "#eed49f" })
  vim.api.nvim_set_hl(0, "MarkviewPalette3Fg", { fg = "#c6a0f6" })
  vim.api.nvim_set_hl(0, "MarkviewPalette4Fg", { fg = "#a6da95" })
  vim.api.nvim_set_hl(0, "MarkviewPalette5Fg", { fg = "#8aadf4" })

  -- 截图中的代码块背景 (深沉有质感)
  vim.api.nvim_set_hl(0, "MarkviewCode", { bg = "#1e2030" })
  vim.api.nvim_set_hl(0, "MarkviewInlineCode", { bg = "#363a4f", fg = "#cad3f5" })
end

set_markview_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_markview_highlights })

safe_require('markview', function(mv)
  local presets = require("markview.presets")
  mv.setup({
    -- 完全使用官方 Github 截图中的预设
    headings = presets.headings.glow_labels,
    markdown = {
      list_items = {
        marker_plus = { add_padding = false },
        marker_minus = { add_padding = false },
        marker_star = { add_padding = false },
      },
    },
  })
end)

-- [物理惯性平滑光标: SmoothCursor]
-- 当在 NeoVim 中上下移动光标时，会拉出一条带物理惯性的彩虹流星拖尾
local function set_smoothcursor_highlights()
  vim.api.nvim_set_hl(0, "SmoothCursor", { fg = "#cad3f5" })
  vim.api.nvim_set_hl(0, "SmoothCursorRed", { fg = "#ed8796" })
  vim.api.nvim_set_hl(0, "SmoothCursorOrange", { fg = "#f5a97f" })
  vim.api.nvim_set_hl(0, "SmoothCursorYellow", { fg = "#eed49f" })
  vim.api.nvim_set_hl(0, "SmoothCursorGreen", { fg = "#a6da95" })
  vim.api.nvim_set_hl(0, "SmoothCursorAqua", { fg = "#8bd5ca" })
  vim.api.nvim_set_hl(0, "SmoothCursorBlue", { fg = "#8aadf4" })
  vim.api.nvim_set_hl(0, "SmoothCursorPurple", { fg = "#c6a0f6" })
end

set_smoothcursor_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_smoothcursor_highlights })

safe_require('smoothcursor', function(sc)
  sc.setup({
    autostart = true,
    cursor = "", -- 光标头部字符 (流星头)
    texthl = "SmoothCursor",
    linehl = nil,
    type = "default", -- default, exp, turtle, wave
    fancy = {
      enable = true, -- 开启 Fancy 拖尾模式
      head = { cursor = "", texthl = "SmoothCursor", linehl = nil },
      body = {
        { cursor = "•", texthl = "SmoothCursorRed" },
        { cursor = "•", texthl = "SmoothCursorOrange" },
        { cursor = "•", texthl = "SmoothCursorYellow" },
        { cursor = "•", texthl = "SmoothCursorGreen" },
        { cursor = "•", texthl = "SmoothCursorAqua" },
        { cursor = "•", texthl = "SmoothCursorBlue" },
        { cursor = "•", texthl = "SmoothCursorPurple" },
      },
      tail = { cursor = " ", texthl = "SmoothCursor" }
    },
    speed = 25, -- 速度 (数值越大移动越快，越小惯性越强，默认25)
    intervals = 35, -- 更新频率
    priority = 10,
    timeout = 3000,
    threshold = 3,
    disable_float_on_trigger = true,
    disabled_filetypes = { "help", "nofile", "prompt", "quickfix", "neo-tree" },
  })
end)

-- [Modern 悬浮 UI: Noice.nvim]
-- 提供极具现代感的浮动命令面板、搜索框、消息通知
safe_require('notify', function(notify)
  notify.setup({
    background_colour = "#1e2030",
    fps = 60,
    render = "default",
    timeout = 3000,
  })
  vim.notify = notify
end)

safe_require('noice', function(noice)
  noice.setup({
    lsp = {
      -- override markdown rendering so that cmp and other plugins use Treesitter
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true, 
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = false, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    views = {
      cmdline_popup = {
        position = {
          row = "30%",
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
      },
      popupmenu = {
        relative = "editor",
        position = {
          row = "40%",
          col = "50%",
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
        },
      },
    },
  })
end)

