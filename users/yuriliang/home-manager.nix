{ config, lib, pkgs, ... }:

let
  sources = import ../../nix/sources.nix;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = (pkgs.writeShellScriptBin "manpager" (if isDarwin then ''
    sh -c 'col -bx | bat -l man -p'
    '' else ''
    cat "$1" | col -bx | bat --language man --style plain
  ''));
in {
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "18.09";

  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = [
    pkgs.bat
    pkgs.fd
    pkgs.fzf
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.tree
    pkgs.watch

    pkgs.gopls
    pkgs.zigpkgs.master
  ] ++ (lib.optionals isLinux [
    pkgs.chromium
    pkgs.firefox
    pkgs.k2pdfopt
    pkgs.rofi
    pkgs.zathura
  ]);

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "${manpager}/bin/manpager";
  };

  home.file.".gdbinit".source = ./gdbinit;
  home.file.".inputrc".source = ./inputrc;

  xdg.configFile."i3/config".text = builtins.readFile ./i3;
  xdg.configFile."rofi/config.rasi".text = builtins.readFile ./rofi;
  xdg.configFile."devtty/config".text = builtins.readFile ./devtty;

  # Rectangle.app. This has to be imported manually using the app.
  xdg.configFile."rectangle/RectangleConfig.json".text = builtins.readFile ./RectangleConfig.json;

  # Nvim config file
  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };

  # tree-sitter parsers
  /* xdg.configFile."nvim/parser/proto.so".source = "${pkgs.tree-sitter-proto}/parser";
  xdg.configFile."nvim/queries/proto/folds.scm".source =
    "${sources.tree-sitter-proto}/queries/folds.scm";
  xdg.configFile."nvim/queries/proto/highlights.scm".source =
    "${sources.tree-sitter-proto}/queries/highlights.scm";
  xdg.configFile."nvim/queries/proto/textobjects.scm".source =
    ./textobjects.scm; */

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = !isDarwin;

  programs.bash = {
    enable = true;
    shellOptions = [];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = builtins.readFile ./bashrc;

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    };
  };

  programs.zsh = {
    enable = true;

    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    defaultKeymap = "emacs";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      save = 20000;
      size = 20000;
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" [
      "source ${sources.theme-bobthefish}/functions/fish_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_title.fish"
      (builtins.readFile ./config.fish)
      "set -g SHELL ${pkgs.fish}/bin/fish"
    ]);

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    } // (if isLinux then {
      # Two decades of using a Mac has made this such a strong memory
      # that I'm just going to keep it consistent.
      pbcopy = "xclip";
      pbpaste = "xclip -o";
    } else {});

    plugins = map (n: {
      name = n;
      src  = sources.${n};
    }) [
      "fish-foreign-env"
      "theme-bobthefish"
    ];
  };

  programs.git = {
    enable = true;
    userName = "leunguu";
    userEmail = "liangy3928@gmail.com";
    signing = {
      key = "E60E9B15F0619B00";
      signByDefault = true;
    };
    aliases = {
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      github.user = "leunguu";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  programs.go = {
    enable = true;
    goPath = "code/go";
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shortcut = "x";
    secureSocket = false;

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"

      set -g @dracula-show-battery false
      set -g @dracula-show-network false
      set -g @dracula-show-weather false

      bind -n C-k send-keys "clear"\; send-keys "Enter"

      run-shell ${sources.tmux-pain-control}/pain_control.tmux
      run-shell ${sources.tmux-dracula}/dracula.tmux
    '';
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty;
  };

  programs.i3status = {
    enable = isLinux;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    package = pkgs.neovim-nightly;

    plugins = with pkgs; [
      vimExtraPlugins.rose-pine
      vimExtraPlugins.nui-nvim
      vimExtraPlugins.nvim-web-devicons
      vimExtraPlugins.neo-tree-nvim
      vimExtraPlugins.lualine-nvim
      vimExtraPlugins.gitsigns-nvim
      vimExtraPlugins.nvim-autopairs

      # telescope
      vimExtraPlugins.plenary-nvim
      vimExtraPlugins.telescope-nvim
      vimPlugins.telescope-ui-select-nvim
      # diagnostic
      vimExtraPlugins.trouble-nvim
      # comment
      vimPlugins.comment-nvim
      vimExtraPlugins.todo-comments-nvim
      # Syntax highlighting
      (vimPlugins.nvim-treesitter.withPlugins
        (p: [
        p.bash p.cmake p.dockerfile p.gitignore p.go p.json p.python p.yaml p.toml p.markdown
        ])
      )

      #LSP
      vimExtraPlugins.nvim-lspconfig
      vimExtraPlugins.goto-preview
      vimPlugins.vim-terraform
      vimExtraPlugins.mason-nvim

      # Linting
      vimExtraPlugins.null-ls-nvim

      # Completion
      vimExtraPlugins.cmp-nvim-lsp
      vimExtraPlugins.cmp-nvim-lua
      vimExtraPlugins.cmp-buffer
      vimExtraPlugins.cmp-path
      vimExtraPlugins.nvim-cmp
      vimExtraPlugins.cmp-cmdline

      # Snippets
      vimExtraPlugins.LuaSnip
      vimExtraPlugins.cmp-luasnip
      vimExtraPlugins.neodev-nvim

      # Others
      vimExtraPlugins.persisted-nvim
      vimExtraPlugins.nvim-treesitter-textobjects

      customVim.lsp-zero
      customVim.nvim-colorizer
      customVim.vim-arsync
    ];

    extraPackages = with pkgs; [
      tree-sitter
      nodejs
      # Language Servers
      # Bash
      nodePackages.bash-language-server
      # Lua
      sumneko-lua-language-server
      # Nix
      rnix-lsp
      nixpkgs-fmt
      statix
      # Python
      nodePackages.pyright
      # python-debug
      black
      # Telescope tools
      fd
    ];

    /* extraConfig = (import ./vim-config.nix) { inherit sources; }; */
    extraConfig = ''
      :luafile ~/.config/nvim/lua/init.lua
    '';
  };

  services.gpg-agent = {
    enable = isLinux;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = lib.mkIf isLinux {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };
}
