{ pkgs, config, ... }:

{
  imports = [ ./nushell ];

  home.username = "chris";
  home.homeDirectory = "/home/chris";

  home.keyboard = {
    layout = "us";
    model = "pc105";
    options = [ "compose:menu" ];
  };

  xsession.enable = true;

  programs.alacritty = {
    enable = true;
    settings.font.size = 10;
  };

  programs.git = {
    enable = true;
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
    userName = "Christoph Blessing";
    userEmail = "chris24.blessing@gmail.com";
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "chris24.blessing@gmail.com";
        name = "Christoph Blessing";
      };
    };
  };

  programs.gpg.enable = true;

  programs.himalaya.enable = true;

  programs.mbsync.enable = true;

  programs.msmtp.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraLuaConfig = ''
      require("setup").setup({lazy_dev_path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start"})
    '';
    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
      lazy-nvim
      gitsigns-nvim
      guess-indent-nvim
      which-key-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      nvim-web-devicons
      plenary-nvim
      nvim-lspconfig
      fidget-nvim
      blink-cmp
      conform-nvim
      luasnip
      lazydev-nvim
      todo-comments-nvim
      mini-nvim
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-autopairs
    ];
    extraPackages = with pkgs; [
      lua-language-server
      pyright
      nixd
      stylua
      nixfmt-rfc-style
    ];
  };

  xdg = {
    configFile."nvim/lua" = {
      recursive = true;
      source = ./neovim;
    };
  };

  programs.zellij.enable = true;
  home.file.".config/zellij/config.kdl" = {
    source = ./zellij/config.kdl;
  };

  programs.rofi.enable = true;

  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "browser.in-content.dark-mode" = true;
        "ui.systemUsesDarkTheme" = 1;
        "browser.sessionstore.resume_from_crash" = false;
        "signon.rememberSignons" = false;
        "browser.translations.automaticallyPopup" = false;
        "browser.aboutConfig.showWarning" = false;
      };
    };
  };

  xsession.windowManager.bspwm = {
    enable = true;
    settings = {
      border_width = 9;
      window_gap = -9;
      top_padding = 30;
      right_padding = 9;
      bottom_padding = 9;
      left_padding = 9;
      split_ratio = 0.5;
      borderless_monocle = true;
      gapless_monocle = true;
      normal_border_color = "#928374";
      focused_border_color = "#cc241d";
      presel_feedback_color = "#b8bb26";
    };
    extraConfig = ''
      loginctl lock-session
    '';
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };
  services.sxhkd = {
    enable = true;
    keybindings = {
      "super + Escape" = "pkill -USR1 -x sxhkd";
      "super + Return" = "alacritty";
      "super + space" = "rofi -show drun";
      "super + {_,shift + }{Left,Down,Up,Right}" = "bspc node -{f,s} {west,south,north,east}";
      "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}'";
      "super + {_,shift + }w" = "bspc node -{c,k}";
      "super + f" = "bspc desktop -l next";
      "control + alt + o" = "oath";
      "control + alt + l" = "${pkgs.i3lock}/bin/i3lock";
    };
  };

  services.ssh-agent.enable = true;

  home.file = {
    keepassxc = {
      enable = true;
      source = ./keepassxc/keepassxc.ini;
      target = ".config/keepassxc/keepassxc.ini";
    };
  };

  home.packages = with pkgs; [
    keepassxc
    git
    ripgrep
    yubikey-manager
    xclip
    (writeScriptBin "oath" (builtins.readFile ./scripts/oath.nu))
    fd
  ];
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
