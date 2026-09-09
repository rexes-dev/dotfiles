print("Running init.lua")

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
    -- treesitter: parses code into a syntax tree; core uses it for
    -- highlighting and folds. Pinned to `master`: `main` builds every parser
    -- with the tree-sitter CLI, `master` needs only a C compiler.
    {
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
      build = ":TSUpdate",
      main = "nvim-treesitter.configs", -- opts go here, not to the root module
      opts = {
        ensure_installed = { "c", "cpp", "cuda", "lua", "python" },
        highlight = { enable = true },
        indent = { enable = true },
      },
    },

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
          on_attach = function(client, bufnr)
            local opts = { buffer = bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)       -- go to definition
            vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)            -- show docs
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)       -- find references
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)   -- rename symbol
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- code actions
            vim.keymap.set("n", "<leader>f",  vim.lsp.buf.format, opts)   -- format file
          end,
        })

        vim.lsp.enable("clangd")  -- explicitly enable it
      end,
    },
  },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

