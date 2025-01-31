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
in
{
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
    pkgs.peco
    pkgs.ghq
    pkgs.jq
    pkgs.ripgrep
    pkgs.tree
    pkgs.watch
    pkgs.direnv
    pkgs.nix-direnv
    pkgs.unzip
    pkgs.cargo
    pkgs.cmake
    pkgs.gcc9

    pkgs.gopls
  ] ++ (lib.optionals isLinux [
    pkgs.firefox
    pkgs.rofi
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
  home.file.".xrandr-4k".source = ./xrandr;
  home.file.".pylintrc".source = ./pylintrc;
  home.file.".flakeinit".source = ./flakeinit;

  home.file.".local/bin" = {
    source = ./tmuxMaster;
    recursive = true;
    executable = true;
  };

  home.file.".local/share/fonts" = {
    source = ./fonts;
    recursive = true;
  };

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

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = !isDarwin;

  programs.bash = {
    enable = true;
    shellOptions = [ ];
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
    shellAliases = {
      xrandr-4k = "bash $HOME/.xrandr-4k";
      flakeinit = "bash $HOME/.flakeinit";
      ll = "exa -l -g --icons";
      ls = "exa --icons";
      gpl = "git pull";
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
      q = "exit";
    };
    initExtra = lib.strings.concatStrings (lib.strings.intersperse "\n" [
      (builtins.readFile ./filters.zsh)
      "if [ -z \"$TMUX\" ]; then tmux attach -t TMUX || tmux new -s TMUX; fi"
      "eval \"$(direnv hook zsh)\""
    ]);
    envExtra = lib.strings.concatStrings (lib.strings.intersperse "\n" [
      "export GHQ_ROOT=\"/host/yurliang/development\""
    ]);
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      character = {
        success_symbol = "[➜](bold bright-green)";
        error_symbol = "[➜](bold bright-red)";
      };
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$localip"
        "$shlvl"
        "$singularity"
        "$kubernetes"
        "$directory"
        "$vcsh"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$hg_branch"
        "$docker_context"
        "$package"
        "$cmake"
        "$golang"
        "$helm"
        "$lua"
        "$nodejs"
        "$pulumi"
        "$python"
        "$ruby"
        "$rust"
        "$terraform"
        "$buf"
        "$nix_shell"
        "$memory_usage"
        "$aws"
        "$gcloud"
        "$openstack"
        "$azure"
        "$env_var"
        "$custom"
        "$sudo"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$status"
        "$container"
        "$shell"
        "$character"
      ];
      aws = {
        disabled = true;
        symbol = "  ";
      };
      buf = {
        symbol = " ";
      };
      directory = {
        read_only = " ";
      };
      docker_context = {
        disabled = true;
        symbol = " ";
      };
      git_branch = {
        symbol = " ";
      };
      golang = {
        symbol = " ";
      };
      hg_branch = {
        symbol = " ";
      };
      java = {
        symbol = " ";
      };
      lua = {
        symbol = " ";
      };
      memory_usage = {
        symbol = " ";
      };
      nix_shell = {
        symbol = " ";
      };
      nodejs = {
        symbol = " ";
      };
      python = {
        symbol = " ";
      };
      ruby = {
        symbol = " ";
      };
      rust = {
        symbol = " ";
      };
    };
  };

  programs.exa = {
    enable = true;
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
    ignores = [ "flake.nix" "flake.lock" ".envrc" ".direnv/" ".env" ];
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
      set-option -g default-terminal "screen-256color"
      run-shell ${sources.tmux-pain-control}/pain_control.tmux
      set -g status-style 'bg=#333333 fg=#5eacd3'
      set -g base-index 1
      set-option -g renumber-windows on
      set -s escape-time 0

      # copy-mode
      bind Enter copy-mode # enter copy mode
      bind r source-file ~/.config/tmux/tmux.conf
      setw -g mode-keys vi

      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'


      # X11 clipboard
      # if -b 'command -v xsel > /dev/null 2>&1' 'bind y run -b "tmux save-buffer - | xsel -i -b"'
      # if -b '! command -v xsel > /dev/null 2>&1 && command -v xclip > /dev/null 2>&1' 'bind y run -b "tmux save-buffer - | xclip -i -selection clipboard >/dev/null 2>&1"'
      # vim tmux navigator
      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l

      bind-key -r f run-shell "tmux neww 'bash ~/.local/bin/tmux-sessioner'"
      bind-key -r i run-shell "tmux neww 'bash ~/.local/bin/tmux-cht'"
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
      customVim.rose-pine
      customVim.nvim-nui
      customVim.nvim-web-devicons
      customVim.neo-tree
      customVim.nvim-lualine
      customVim.nvim-gitsigns
      customVim.nvim-autopairs

      # telescope
      customVim.nvim-plenary
      customVim.nvim-telescope
      customVim.telescope-ui-select
      # diagnostic
      customVim.nvim-trouble
      # comment
      customVim.nvim-comment
      customVim.todo-comments
      # Syntax highlighting
      (vimPlugins.nvim-treesitter.withPlugins
        (p: [
          p.bash
          p.cmake
          p.dockerfile
          p.gitignore
          p.go
          p.json
          p.python
          p.yaml
          p.toml
          p.markdown
        ])
      )

      #LSP
      # customVim.lsp-zero
      customVim.lsp-signature
      customVim.nvim-lspconfig
      customVim.mason
      customVim.mason-lspconfig
      vimPlugins.vim-terraform
      customVim.goto-preview

      # Linting
      customVim.null-ls

      # Completion
      customVim.cmp-nvim-lsp
      customVim.cmp-nvim-lua
      customVim.cmp-buffer
      customVim.cmp-path
      customVim.nvim-cmp
      customVim.cmp-cmdline
      customVim.lspkind

      # Snippets
      customVim.LuaSnip
      customVim.cmp-luasnip
      customVim.nvim-neodev

      # Others
      customVim.nvim-persisted
      vimExtraPlugins.nvim-treesitter-textobjects
      customVim.nvim-surround
      vimPlugins.vim-tmux-navigator

      customVim.nvim-colorizer
      customVim.vim-arsync
    ];

    extraPackages = with pkgs; [
      tree-sitter
      nodejs
      luajitPackages.luarocks
    ];

    extraConfig = ''
      :luafile ~/.config/nvim/lua/init.lua
      :luafile ~/.config/nvim/lua/null-ls.lua
      :luafile ~/.config/nvim/lua/persisted.lua
      :luafile ~/.config/nvim/lua/yank-highlight.lua
      :luafile ~/.config/nvim/lua/nvim-surround.lua
      :luafile ~/.config/nvim/lua/gitsigns.lua
      :luafile ~/.config/nvim/lua/todo-comments.lua
      :luafile ~/.config/nvim/lua/autopairs.lua
      :luafile ~/.config/nvim/lua/colorizer.lua
      :luafile ~/.config/nvim/lua/goto-preview.lua
      :luafile ~/.config/nvim/lua/lsp.lua
      :luafile ~/.config/nvim/lua/nvim-cmp.lua
      :luafile ~/.config/nvim/lua/neotree.lua
      :luafile ~/.config/nvim/lua/telescope.lua
      :luafile ~/.config/nvim/lua/treesitter.lua
      :luafile ~/.config/nvim/lua/trouble.lua
      :luafile ~/.config/nvim/lua/comment.lua
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
