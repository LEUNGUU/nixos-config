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
    pkgs.peco
    pkgs.ghq
    pkgs.jq
    pkgs.ripgrep
    pkgs.tree
    pkgs.watch

    pkgs.gopls
  ] ++ (lib.optionals isLinux [
    pkgs.firefox
    pkgs.k2pdfopt
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
    shellAliases = {
      ll="exa -l -g --icons";
      ls = "exa --icons";
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
    initExtra = lib.strings.concatStrings (lib.strings.intersperse "\n" [
      (builtins.readFile ./filters.zsh)
    ]);
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[➜](bold red)";
    };
    settings = {
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
        format = "\\[[$symbol($profile)(\\($region\))(\\[$duration\\])]($style)\\]";
      };
      buf = {
        symbol = " ";
      };
      cmake = {
        format = "\\[[$symbol($version)]($style)\\]";
      };
      cmd_duration = {
        format = "\\[[$duration]($style)\\]";
      };
      directory = {
        read_only = " ";
      };
      docker_context = {
        disabled = true;
        symbol = " ";
        format = "\\[[$symbol$context]($style)\\]";
      };
      git_branch = {
        symbol = " ";
        format = "\\[[$symbol$branch]($style)\\]";
      };
      git_status = {
        stashed = "";
        format = "([\\[$all_status$ahead_behind\\]]($style))";
      };
      golang = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      helm = {
        format = "\\[[$symbol($version)]($style)\\]";
      };
      hg_branch = {
        symbol = " ";
        format = "\\[[$symbol$branch]($style)\\]";
      };
      java = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      kubernetes = {
        format = "\\[[$symbol$context( \\($namespace\\))]($style)\\]";
      };
      lua = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      memory_usage = {
        symbol = " ";
        format = "\\[$symbol[$ram( | $swap)]($style)\\]";
      };
      nix_shell = {
        symbol = " ";
        format = "\\[[$symbol$state( \\($name\\))]($style)\\]";
      };
      nodejs = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      openstack = {
        format = "\\[[$symbol$cloud(\\($project\\))]($style)\\]";
      };
      pulumi = {
        format = "\\[[$symbol$stack]($style)\\]";
      };
      python = {
        symbol = " ";
        format = "\\[[\${symbol}\${pyenv_prefix}(\${version})(\\($virtualenv\\))]($style)\\]";
      };
      ruby = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      rust = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      sudo = {
        format = "\\[[as $symbol]\\]";
      };
      terraform = {
        format = "\\[[$symbol$workspace]($style)\\]";
      };
      time = {
        format = "\\[[$time]($style)\\]";
      };
      username = {
        format = "\\[[$user]($style)\\]";
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

      run-shell ${sources.tmux-pain-control}/pain_control.tmux
      run-shell ${sources.tmux-dracula}/dracula.tmux
      set -g base-index 1
      set-option -g renumber-windows on
      # copy-mode
      bind Enter copy-mode # enter copy mode

      run -b 'tmux bind -t vi-copy v begin-selection 2> /dev/null || true'
      run -b 'tmux bind -T copy-mode-vi v send -X begin-selection 2> /dev/null || true'
      run -b 'tmux bind -t vi-copy C-v rectangle-toggle 2> /dev/null || true'
      run -b 'tmux bind -T copy-mode-vi C-v send -X rectangle-toggle 2> /dev/null || true'
      run -b 'tmux bind -t vi-copy y copy-selection 2> /dev/null || true'
      run -b 'tmux bind -T copy-mode-vi y send -X copy-selection-and-cancel 2> /dev/null || true'
      run -b 'tmux bind -t vi-copy Escape cancel 2> /dev/null || true'
      run -b 'tmux bind -T copy-mode-vi Escape send -X cancel 2> /dev/null || true'
      run -b 'tmux bind -t vi-copy H start-of-line 2> /dev/null || true'
      run -b 'tmux bind -T copy-mode-vi H send -X start-of-line 2> /dev/null || true'
      run -b 'tmux bind -t vi-copy L end-of-line 2> /dev/null || true'
      run -b 'tmux bind -T copy-mode-vi L send -X end-of-line 2> /dev/null || true'
      # X11 clipboard
      if -b 'command -v xsel > /dev/null 2>&1' 'bind y run -b "tmux save-buffer - | xsel -i -b"'
      if -b '! command -v xsel > /dev/null 2>&1 && command -v xclip > /dev/null 2>&1' 'bind y run -b "tmux save-buffer - | xclip -i -selection clipboard >/dev/null 2>&1"'
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
      vimExtraPlugins.nvim-surround

      customVim.lsp-zero
      customVim.nvim-colorizer
      customVim.vim-arsync
      customVim.mason-lspconfig
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
    ];

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
