print("Running init.lua")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true

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
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {
        style = "night", -- storm, night, moon, day
      },
      config = function(_, opts)
        require("tokyonight").setup(opts)
        vim.cmd("colorscheme tokyonight")
      end,
    },

    -- treesitter
    {
      -- TODO(rexes): Need to study the details
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
      build = ":TSUpdate",
      opts = {
        ensure_installed = {
          "cpp", "c", -- C/C++
          "lua", -- for editing nvim config
          "vim", "vimdoc"  -- vim help files
        },

        sync_install = false,

        -- Enable syntax highlighting
        highlight = { enable = true, },

        -- Enable indentation (better than Neovim's default for C++)
        indent = { enable = true },
      },
    },

    -- LSP
    {
      "mason-org/mason-lspconfig.nvim",
      opts = {
        ensure_installed = { "clangd" },
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
  install = { colorscheme = { "tokyonight", "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

