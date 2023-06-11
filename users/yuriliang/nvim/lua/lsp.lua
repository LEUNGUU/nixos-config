-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.ensure_installed({'jedi_language_server', 'dockerls', 'jsonls', 'lua_ls'})

require('mason').setup({ensure_installed = {'black'}})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {error = '✘', warn = '▲', hint = '⚑', info = '»'}
})

lsp.setup_nvim_cmp({
    sources = {
        {name = 'nvim_lsp', group_index = 1}, {
            name = 'buffer',
            option = {
                get_bufnrs = function()
                    return vim.api.nvim_list_bufs()
                end,
                group_index = 2
            }
        }, {name = 'path', group_index = 2}
    }
})

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

lsp.on_attach(function(client, bufnr)
    local opts = {buffer = bufnr, remap = false}

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    -- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<leader>sh", vim.lsp.buf.signature_help, opts)
end)

vim.diagnostic.config({
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    virtual_text = {spacing = 4, prefix = '●'}
})
lsp.setup()
