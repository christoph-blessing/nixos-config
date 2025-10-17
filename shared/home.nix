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

  programs.alacritty = {
    enable = true;
    settings = {
      font.size = 10;
      env.WINIT_X11_SCALE_FACTOR = "1";
    };
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

  programs.gpg.enable = true;

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

  programs.wofi.enable = true;

  services.kanshi = {
    enable = true;
    profiles = {
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      };
      docked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-3";
            status = "enable";
          }
        ];
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,auto";
      "$terminal" = "alacritty";
      "$menu" = "wofi --show drun";
      "exec-once" = "kanshi & waybar &";
      "env" = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];
      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
      windowrule = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "idle_inhibitor"
          "cpu"
          "memory"
          "disk"
          "network"
          "backlight"
          "battery"
          "clock"
        ];
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };
        memory = {
          format = "{}% ";
        };
        disk = {
          format = "{percentage_used}% 🖴";
        };
        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} ";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        clock = {
          format-alt = "{:%Y-%m-%d}";
          tooltip = false;
        };
      };
    };
  };

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

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
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
    font-awesome
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
