self: super:

let sources = import ../../nix/sources.nix; in rec {
  # My vim config
  customVim = with self; {
    rose-pine = vimUtils.buildVimPlugin{
      name = "rose-pine";
      src = sources.rose-pine;
      buildPhase = ":";
    };

    lsp-zero = vimUtils.buildVimPlugin{
      name = "lsp-zero";
      src = sources.lsp-zero;
      buildPhase = ":";
    };

    mason = vimUtils.buildVimPlugin{
      name = "mason";
      src = sources.mason;
      buildPhase = ":";
    };

    mason-lspconfig = vimUtils.buildVimPlugin{
      name = "mason-lspconfig";
      src = sources.mason-lspconfig;
      buildPhase = ":";
    };

    nvim-cmp = vimUtils.buildVimPlugin{
      name = "nvim-cmp";
      src = sources.nvim-cmp;
      buildPhase = ":";
    };

    cmp-buffer = vimUtils.buildVimPlugin{
      name = "cmp-buffer";
      src = sources.cmp-buffer;
      buildPhase = ":";
    };

    cmp-path = vimUtils.buildVimPlugin{
      name = "cmp-path";
      src = sources.cmp-path;
      buildPhase = ":";
    };

    cmp-nvim-lsp = vimUtils.buildVimPlugin{
      name = "cmp-nvim-lsp";
      src = sources.cmp-nvim-lsp;
      buildPhase = ":";
    };

    cmp-nvim-lua = vimUtils.buildVimPlugin{
      name = "cmp-nvim-lua";
      src = sources.cmp-nvim-lua;
      buildPhase = ":";
    };

    LuaSnip = vimUtils.buildVimPlugin{
      name = "LuaSnip";
      src = sources.LuaSnip;
      buildPhase = ":";
    };

    neo-tree = vimUtils.buildVimPlugin{
      name = "neo-tree";
      src = sources.neo-tree;
      buildPhase = ":";
    };

    cmp_luasnip = vimUtils.buildVimPlugin{
      name = "cmp_luasnip";
      src = sources.cmp_luasnip;
      buildPhase = ":";
    };

    nvim-web-devicons = vimUtils.buildVimPlugin{
      name = "nvim-web-devicons";
      src = sources.nvim-web-devicons;
      buildPhase = ":";
    };

    nvim-nui = vimUtils.buildVimPlugin{
      name = "nvim-nui";
      src = sources.nvim-nui;
      buildPhase = ":";
    };

    nvim-persisted = vimUtils.buildVimPlugin{
      name = "nvim-persisted";
      src = sources.nvim-persisted;
      buildPhase = ":";
    };

    nvim-autopairs = vimUtils.buildVimPlugin{
      name = "nvim-autopairs";
      src = sources.nvim-autopairs;
      buildPhase = ":";
    };

    nvim-gitsigns = vimUtils.buildVimPlugin{
      name = "nvim-gitsigns";
      src = sources.nvim-gitsigns;
      buildPhase = ":";
    };

    null-ls = vimUtils.buildVimPlugin{
      name = "null-ls";
      src = sources.null-ls;
      buildPhase = ":";
    };

    nvim-lualine = vimUtils.buildVimPlugin{
      name = "nvim-lualine";
      src = sources.nvim-lualine;
      buildPhase = ":";
    };

    telescope-ui-select = vimUtils.buildVimPlugin{
      name = "telescope-ui-select";
      src = sources.telescope-ui-select;
      buildPhase = ":";
    };

    nvim-colorizer = vimUtils.buildVimPlugin{
      name = "nvim-colorizer";
      src = sources.nvim-colorizer;
      buildPhase = ":";
    };

    goto-preview = vimUtils.buildVimPlugin{
      name = "goto-preview";
      src = sources.goto-preview;
      buildPhase = ":";
    };

    nvim-neodev = vimUtils.buildVimPlugin{
      name = "nvim-neodev";
      src = sources.nvim-neodev;
      buildPhase = ":";
    };

    lsp-signature = vimUtils.buildVimPlugin{
      name = "lsp-signature";
      src = sources.lsp-signature;
      buildPhase = ":";
    };

    todo-comments = vimUtils.buildVimPlugin{
      name = "todo-comments";
      src = sources.todo-comments;
      buildPhase = ":";
    };

    nvim-trouble = vimUtils.buildVimPlugin{
      name = "nvim-trouble";
      src = sources.nvim-trouble;
    };

    nvim-surround = vimUtils.buildVimPlugin{
      name = "nvim-surround";
      src = sources.nvim-surround;
      buildPhase = ":";
    };

    vim-arsync = vimUtils.buildVimPlugin{
      name = "vim-arsync";
      src = sources.vim-arsync;
      buildPhase = ":";
    };

    vim-terraform = vimUtils.buildVimPlugin{
      name = "vim-terraform";
      src = sources.vim-terraform;
      buildPhase = ":";
    };

    nvim-comment = vimUtils.buildVimPlugin {
      name = "nvim-comment";
      src = sources.nvim-comment;
      buildPhase = ":";
    };

    nvim-plenary = vimUtils.buildVimPlugin {
      name = "nvim-plenary";
      src = sources.nvim-plenary;
      buildPhase = ":";
    };

    nvim-telescope = vimUtils.buildVimPlugin {
      name = "nvim-telescope";
      src = sources.nvim-telescope;
      buildPhase = ":";
    };

    nvim-treesitter = vimUtils.buildVimPlugin {
      name = "nvim-treesitter";
      src = sources.nvim-treesitter;
    };

    nvim-treesitter-playground = vimUtils.buildVimPlugin {
      name = "nvim-treesitter-playground";
      src = sources.nvim-treesitter-playground;
    };

    nvim-lspconfig = vimUtils.buildVimPlugin {
      name = "nvim-lspconfig";
      src = sources.nvim-lspconfig;

      # We have to do this because the build phase runs tests which require
      # git and I don't know how to get git into here.
      buildPhase = ":";
    };

    nvim-treesitter-textobjects = vimUtils.buildVimPlugin {
      name = "nvim-treesitter-textobjects";
      src = sources.nvim-treesitter-textobjects;
    };
  };
}
