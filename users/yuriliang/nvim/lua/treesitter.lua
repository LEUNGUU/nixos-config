-- plugin: nvim-treesitter
-- see: https://github.com/nvim-treesitter/nvim-treesitter

-- Setup treesitter
require('nvim-treesitter.configs').setup({
    -- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },

    indent = {
        enable = true,
    },

    refactor = {
        highlight_definitions = { enable = true },
        highlight_current_scope = { enable = true },
    },

})

