{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "chris";
  home.homeDirectory = "/home/chris";

  home.keyboard = {
    layout = "us";
    model = "pc105";
    options = [
      "compose:menu"
    ];
  };

  xsession.enable = true;

  programs.git = {
    enable = true;
    userName = "Christoph Blessing";
    userEmail = "chris24.blessing@gmail.com";
  };

  programs.gpg.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ":luafile ${neovim/init.lua}";
    plugins = with pkgs.vimPlugins; [
      vim-sleuth
      comment-nvim
      gitsigns-nvim
      which-key-nvim
      telescope-nvim
      nvim-lspconfig
      fidget-nvim
      neodev-nvim
      nvim-cmp
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      cmp-path
      tokyonight-nvim
      conform-nvim
      todo-comments-nvim
      mini-nvim
      nvim-treesitter.withAllGrammars
    ];
  };

  programs.nushell = {
    enable = true;
    configFile.source = nushell/config.nu;
    envFile.source = nushell/env.nu;
  };

  programs.zellij = {
    enable = true;
  };

  programs.rofi.enable = true;

  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "browser.in-content.dark-mode" = true;
        "ui.systemUsesDarkTheme" = 1;
      };
    };
  };

  xsession.windowManager.bspwm = {
    enable = true;
    monitors = {
      DP-1 = [
        "I"
        "II"
        "III"
        "IV"
        "V"
      ];
    };
    settings = {
      border_width = 9;
      window_gap = -9;
      top_padding = 9;
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
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "curses";
  };

  services.sxhkd = {
    enable = true;
    keybindings = {
      "super + Escape" = "pkill -USR1 -x sxhkd";
      "super + Return" = "st";
      "super + space" = "rofi -show drun";
      "super + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}";
      "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}'";
      "super + {_,shift + }w" = "bspc node -{c,k}";
      "alt + o" = "oath";
    };
  };

  home.packages = with pkgs; [
    keepassxc
    mattermost-desktop
    git
    lua-language-server
    stylua
    ripgrep
    yubikey-manager
    xclip
    (writeScriptBin "oath" (builtins.readFile ./scripts/oath.nu))
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

