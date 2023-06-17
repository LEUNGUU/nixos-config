local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {'pylsp', 'dockerls', 'jsonls', 'lua_ls', 'bashls'}
})

local custom_attach = function(client, bufnr)
    -- Mappings.
    local map = function(mode, l, r, opts)
        opts = opts or {}
        opts.silent = true
        opts.buffer = bufnr
        keymap.set(mode, l, r, opts)
    end

    map("n", "gd", vim.lsp.buf.definition, {desc = "go to definition"})
    map("n", "<C-]>", vim.lsp.buf.definition)
    map("n", "K", vim.lsp.buf.hover)
    map("n", "<C-k>", vim.lsp.buf.signature_help)
    map("n", "<leader>rn", vim.lsp.buf.rename, {desc = "varialbe rename"})
    map("n", "gr", vim.lsp.buf.references, {desc = "show references"})
    map("n", "[d", diagnostic.goto_prev, {desc = "previous diagnostic"})
    map("n", "]d", diagnostic.goto_next, {desc = "next diagnostic"})
    map("n", "<leader>q", diagnostic.setqflist, {desc = "put diagnostic to qf"})
    map("n", "<leader>ca", vim.lsp.buf.code_action, {desc = "LSP code action"})
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder,
        {desc = "add workspace folder"})
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder,
        {desc = "remove workspace folder"})
    map("n", "<leader>wl",
        function() inspect(vim.lsp.buf.list_workspace_folders()) end,
        {desc = "list workspace folder"})

    -- Set some key bindings conditional on server capabilities
    if client.server_capabilities.documentFormattingProvider then
        map("n", "<leader>f", vim.lsp.buf.format, {desc = "format code"})
    end

    api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        callback = function()
            local float_opts = {
                focusable = false,
                close_events = {
                    "BufLeave", "CursorMoved", "InsertEnter", "FocusLost"
                },
                border = "rounded",
                source = "always", -- show source in diagnostic popup window
                prefix = " "
            }

            if not vim.b.diagnostics_pos then
                vim.b.diagnostics_pos = {nil, nil}
            end

            local cursor_pos = api.nvim_win_get_cursor(0)
            if (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~=
                vim.b.diagnostics_pos[2]) and #diagnostic.get() > 0 then
                diagnostic.open_float(nil, float_opts)
            end

            vim.b.diagnostics_pos = cursor_pos
        end
    })

    -- The blow command will highlight the current variable and its usages in the buffer.
    if client.server_capabilities.documentHighlightProvider then
        vim.cmd([[
      hi! link LspReferenceRead Visual
      hi! link LspReferenceText Visual
      hi! link LspReferenceWrite Visual
    ]])

        local gid = api.nvim_create_augroup("lsp_document_highlight",
                                            {clear = true})
        api.nvim_create_autocmd("CursorHold", {
            group = gid,
            buffer = bufnr,
            callback = function() lsp.buf.document_highlight() end
        })

        api.nvim_create_autocmd("CursorMoved", {
            group = gid,
            buffer = bufnr,
            callback = function() lsp.buf.clear_references() end
        })
    end

    if vim.g.logging_level == "debug" then
        local msg = string.format("Language server %s started!", client.name)
        vim.notify(msg, vim.log.levels.DEBUG, {title = "betterme"})
    end
end

lspconfig.pylsp.setup({
    on_attach = custom_attach,
    settings = {
        pylsp = {
            plugins = {
                pylint = {enabled = true, executable = "pylint"},
                pyflakes = {enabled = false},
                pycodestyle = {enabled = false},
                jedi_completion = {fuzzy = true},
                pyls_isort = {enabled = true},
                pylsp_mypy = {enabled = true}
            }
        }
    },
    flags = {debounce_text_changes = 200},
    capabilities = capabilities
})
lspconfig.bashls.setup({on_attach = custom_attach, capabilities = capabilities})

lspconfig.lua_ls.setup {
    on_attach = custom_attach,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT"
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {"vim"}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files,
                -- see also https://github.com/LuaLS/lua-language-server/wiki/Libraries#link-to-workspace .
                -- Lua-dev.nvim also has similar settings for lua ls, https://github.com/folke/neodev.nvim/blob/main/lua/neodev/luals.lua .
                library = {
                    fn.stdpath("data") .. "/site/pack/packer/opt/emmylua-nvim",
                    fn.stdpath("config")
                },
                maxPreload = 2000,
                preloadFileSize = 50000
            }
        }
    },
    capabilities = capabilities
}

fn.sign_define("DiagnosticSignError",
               {text = ' ', texthl = "DiagnosticSignError"}) --   ✘
fn.sign_define("DiagnosticSignWarn",
               {text = '󰀪 ', texthl = "DiagnosticSignWarn"}) -- 󰀪 󰳤 󱦄 󱗓 
fn.sign_define("DiagnosticSignInformation",
               {text = ' ', texthl = "DiagnosticSignInfo"}) --    ⁱ 󰋼 󰋽
fn.sign_define("DiagnosticSignHint",
               {text = ' ', texthl = "DiagnosticSignHint"}) --  󰌶 

-- global config for diagnostic
diagnostic.config {
    underline = false,
    virtual_text = false,
    signs = true,
    severity_sort = true
}

lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover,
                                              {border = "rounded"})
