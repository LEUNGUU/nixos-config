local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
    preselect = 'item',
    completion = {keyword_length = 1, completeopt = 'menu,menuone,noinsert'},
    sources = {
        {name = 'nvim_lsp', priority = 50}, {name = 'path', priority = 40},
        {name = 'luasnip', keyword_length = 2, priority = 30},
        {name = 'nvim_lua', priority = 50}, {
            name = 'buffer',
            priority = 50,
            keyword_length = 3,
            option = {
                get_bufnrs = function()
                    return vim.api.nvim_list_bufs()
                end
            }
        }
    },
    mapping = cmp.mapping.preset.insert {
        ["<Tab>"] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end,
        ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end,
        ["<CR>"] = cmp.mapping.confirm {select = true},
        ["<C-e>"] = cmp.mapping.abort(),
        ["<Esc>"] = cmp.mapping.close(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4)
    },
    view = {entries = "custom"},
    formatting = {
        format = lspkind.cmp_format {
            mode = "symbol_text",
            menu = {
                nvim_lsp = "[LSP]",
                ultisnips = "[US]",
                nvim_lua = "[Lua]",
                path = "[Path]",
                buffer = "[Buffer]",
                emoji = "[Emoji]",
                omni = "[Omni]"
            }
        }
    }
})
