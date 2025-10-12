return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",                              
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                -- Only install C++ and Lua parsers
                ensure_installed = { "cpp", "c", "lua" },

                -- Automatically install missing parsers on buffer open
                auto_install = true,

                -- Highlight code using Tree-sitter
                highlight = {
                    enable = true,
                    -- Disable Tree-sitter for large files (>100 KB)
                    disable = function(lang, buf)
                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                    additional_vim_regex_highlighting = false,
                },
            })
        end,
    },
}

