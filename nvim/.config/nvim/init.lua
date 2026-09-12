--==== leader ====--
-- must come before lazy.nvim, plugin specs capture <leader> at load time
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

--==== options ====--
vim.opt.number = true
vim.opt.relativenumber = true

-- built-in gruvbox (same palette, hard background)
vim.cmd.colorscheme("retrobox")

-- show whitespace
vim.opt.list = true
vim.opt.listchars = {
  space = "·",
  tab = "» ",
}

-- <Tab> becomes space
vim.opt.expandtab = true

-- <Tab> visually "tabstop" spaces wide
vim.opt.tabstop = 2

-- indentations (>>, <<), fix indentation (==)
vim.opt.shiftwidth = 2

-- reload the buffer when the file changed on disk (git checkout, external edits)
vim.opt.autoread = true

-- keep the sign column open; otherwise the whole buffer shifts two columns
-- sideways every time a diagnostic appears and clears as you type
vim.opt.signcolumn = "yes"

-- To show messages inline all the time without any command
vim.diagnostic.config({ virtual_text = true })

--==== autocmds ====--
-- autoread only acts when nvim checks; these events make it check
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

--==== bootstrap ====--
-- For more details: https://lazy.folke.io/installation
-- It is recommended to run :checkhealth lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

--==== plugins ====--
require("lazy").setup({
  spec = {
    -- lazydev: gives lua_ls Neovim's API types, so `vim` resolves instead of
    -- warning "Undefined global"
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } }, -- vim.uv types
        },
      },
    },

    -- completion
    { "saghen/blink.cmp", version = "1.*", opts = {} },

    -- fuzzy finder; needs the fzf binary on PATH
    {
      "ibhagwan/fzf-lua",
      opts = {},
      keys = {
        { "<leader>ff", function() require("fzf-lua").files() end,                      desc = "find files" },
        { "<leader>fg", function() require("fzf-lua").live_grep() end,                  desc = "live grep" },
        { "<leader>fw", function() require("fzf-lua").grep_cword() end,                 desc = "grep word under cursor" },
        { "<leader>fb", function() require("fzf-lua").buffers() end,                    desc = "buffers" },
        { "<leader>fo", function() require("fzf-lua").oldfiles() end,                   desc = "recent files" },
        { "<leader>fs", function() require("fzf-lua").lsp_live_workspace_symbols() end, desc = "workspace symbols" },
        { "<leader>fd", function() require("fzf-lua").diagnostics_workspace() end,      desc = "diagnostics" },
        { "<leader>fc", function() require("fzf-lua").git_status() end,                 desc = "changed files" },
        { "<leader>fk", function() require("fzf-lua").keymaps() end,                    desc = "keymaps" },
        { "<leader>fr", function() require("fzf-lua").resume() end,                     desc = "resume last picker" },
      },
    },

    -- file explorer: a directory is just a buffer you edit
    {
      "stevearc/oil.nvim",
      -- upstream advises against lazy loading; oil has to claim directory
      -- buffers before anything else opens one
      lazy = false,
      opts = {
        view_options = { show_hidden = true },
      },
      keys = {
        { "-", "<cmd>Oil<cr>", desc = "open parent directory" },
      },
    },

    -- git diff markers in the sign column
    {
      "lewis6991/gitsigns.nvim",
      event = { "BufReadPre", "BufNewFile" },
      opts = {
        -- mappings follow the gitsigns README, buffer-local so they exist only
        -- where gitsigns attached
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          -- ]c/[c must stay diff motions when an actual diff window is open
          map("n", "]c", function()
            if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
          end, "next hunk")
          map("n", "[c", function()
            if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
          end, "prev hunk")

          -- trimmed set; everything else is reachable as :Gitsigns <action>
          map("n", "<leader>hp", gs.preview_hunk, "preview hunk")
          map("n", "<leader>hs", gs.stage_hunk, "stage hunk")
          map("n", "<leader>hr", gs.reset_hunk, "reset hunk")
          map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "stage selection")
          map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "reset selection")
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "blame line")
        end,
      },
    },

    -- LSP: server installation and enablement
    {
      "mason-org/mason-lspconfig.nvim",
      opts = {
        -- lua_ls was already auto-enabled (mason-lspconfig enables any
        -- installed server); name it now that lazydev needs it
        ensure_installed = { "clangd", "lua_ls" },
        -- stylua has an --lsp mode, so mason-lspconfig counts it as a server
        automatic_enable = { exclude = { "stylua" } },
      },
      dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
      },
    },

    -- LSP: clangd settings and the buffer-local keymaps for any attached server
    {
      "neovim/nvim-lspconfig",
      dependencies = { "saghen/blink.cmp" },
      config = function()
        vim.lsp.config("clangd", {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
        })

        -- no on_attach here: it would replace nvim-lspconfig's, which is what
        -- registers :LspClangdSwitchSourceHeader

        -- Neovim already maps grn rename, gra code action, grr references, gri
        -- implementation, grt type definition, gO symbols, K hover. Only add what
        -- it doesn't, and route the list-producing ones through fzf-lua for the
        -- preview.
        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("my.lsp", {}),
          callback = function(ev)
            local opts = { buffer = ev.buf }
            local fzf_lua = require("fzf-lua")
            vim.keymap.set("n", "gd", fzf_lua.lsp_definitions, opts)                        -- definitions
            vim.keymap.set("n", "grr", fzf_lua.lsp_references, opts)                        -- references
            vim.keymap.set("n", "gO", fzf_lua.lsp_document_symbols, opts)                   -- symbols in file
            vim.keymap.set("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", opts) -- header <-> source
            vim.keymap.set({ "n", "v" }, "<leader>cf", vim.lsp.buf.format, opts)            -- format
            vim.keymap.set("n", "<leader>th", function()                                    -- toggle inlay hints
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
            end, opts)
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end,
        })
      end,
    },
  },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
