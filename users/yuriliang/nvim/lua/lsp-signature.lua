local cfg = {
    bind = true,
    handler_opts = {
        border = "rounded"
    },
    wrap = true,
    doc_lines = 20,
    floating_window = false,
}
require "lsp_signature".setup(cfg)

