vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true

-- built-in gruvbox (same palette, hard background)
vim.cmd.colorscheme("retrobox")

-- show whitespace
vim.opt.list = true
vim.opt.listchars = {
  space = "·",
}

-- <Tab> becomes space
vim.opt.expandtab = true

-- <Tab> visually "tabstop" spaces wide
vim.opt.tabstop = 2

-- indentations (>>, <<), fix indentation (==)
vim.opt.shiftwidth = 2

-- reload the buffer when the file changed on disk (git checkout, external edits)
vim.opt.autoread = true

-- autoread only acts when nvim checks; these events make it check
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

-- To show messages inline all the time without any command
vim.diagnostic.config({ virtual_text = true })

-- keep the sign column open; otherwise the whole buffer shifts two columns
-- sideways every time a diagnostic appears and clears as you type
vim.opt.signcolumn = "yes"

-- Neovim already maps grn rename, gra code action, grr references, gri
-- implementation, grt type definition, gO symbols, K hover. Only add what it
-- doesn't, and route the list-producing ones through fzf-lua for the preview.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    local fzf_lua = require("fzf-lua")
    vim.keymap.set("n", "gd", fzf_lua.lsp_definitions, opts)        -- definitions
    vim.keymap.set("n", "grr", fzf_lua.lsp_references, opts)        -- references
    vim.keymap.set("n", "gO", fzf_lua.lsp_document_symbols, opts)   -- symbols in file
    vim.keymap.set("n", "<leader>h", "<cmd>LspClangdSwitchSourceHeader<cr>", opts)              -- header <-> source
    vim.keymap.set({ "n", "v" }, "<leader>cf", vim.lsp.buf.format, opts)                        -- format
    vim.keymap.set("n", "<leader>th", function()                                                -- toggle inlay hints
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
    end, opts)
    vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
  end,
})

-- For more details: https://lazy.folke.io/installation
-- It is recommended to run :checkhealth lazy
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

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
        { "<leader>ff", function() require("fzf-lua").files() end, desc = "find files" },
        { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "live grep" },
        { "<leader>fw", function() require("fzf-lua").grep_cword() end, desc = "grep word under cursor" },
        { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "buffers" },
        { "<leader>fo", function() require("fzf-lua").oldfiles() end, desc = "recent files" },
        { "<leader>fs", function() require("fzf-lua").lsp_live_workspace_symbols() end, desc = "workspace symbols" },
        { "<leader>fd", function() require("fzf-lua").diagnostics_workspace() end, desc = "diagnostics" },
        { "<leader>fc", function() require("fzf-lua").git_status() end, desc = "changed files" },
        { "<leader>fk", function() require("fzf-lua").keymaps() end, desc = "keymaps" },
        { "<leader>fr", function() require("fzf-lua").resume() end, desc = "resume last picker" },
      },
    },

    -- LSP
    {
      "mason-org/mason-lspconfig.nvim",
      opts = {
        -- lua_ls was already auto-enabled (mason-lspconfig enables any
        -- installed server); name it now that lazydev needs it
        ensure_installed = { "clangd", "lua_ls" },
      },
      dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
      }
    },

    -- clangd
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
      end,
    },
  },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

