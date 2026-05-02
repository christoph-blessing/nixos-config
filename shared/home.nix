{
  pkgs,
  config,
  lib,
  pymodoro,
  ...
}:

{
  imports = [
    ./nushell
    ./pymodoro/pymodoro.nix
  ];

  home.username = "chris";
  home.homeDirectory = "/home/chris";

  programs.alacritty = {
    enable = true;
    settings = {
      font.size = 10;
      env.WINIT_X11_SCALE_FACTOR = "1";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      init = {
        defaultBranch = "main";
      };
      user = {
        name = "Christoph Blessing";
        email = "chris24.blessing@gmail.com";
      };
    };
    signing.format = null;
  };

  programs.gpg.enable = true;

  programs.mbsync.enable = true;

  programs.msmtp.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    initLua = ''
      local xdg_data_home = "${config.xdg.dataHome}"
      require("setup").setup({lazy_dev_path=xdg_data_home .. "/nvim/site/pack/hm/start"})
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
      indent-blankline-nvim
    ];
    extraPackages = with pkgs; [
      lua-language-server
      nixd
      stylua
      nixfmt
    ];
    withRuby = true;
    withPython3 = true;
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

  programs.hyprlock = {
    enable = true;
    settings = {

      "$font" = "Monospace";

      general = {
        hide_cursor = false;
      };

      animations.enabled = false;

      background = {
        monitor = "";
        path = "screenshot";
        blur_passes = 3;
      };

      input-field = {
        hide_input = true;
        monitor = "";
        size = "20%, 5%";
        outline_thickness = 3;
        inner_color = "rgba(0, 0, 0, 0.0)";

        outer_color = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        check_color = "rgba(00ff99ee) rgba(ff6633ee) 120deg";
        fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";

        font_color = "rgb(143, 143, 143)";
        fade_on_empty = false;
        rounding = 15;

        font_family = "$font";
        placeholder_text = "Input password...";
        fail_text = "$PAMFAIL";

        dots_spacing = 0.3;

        position = "0, -20";
        halign = "center";
        valign = "center";
      };
      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 90;
          font_family = "$font";

          position = "-30, 0";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "";
          text = "cmd[update:60000] date +\"%A, %d %B %Y\"";
          font_size = 25;
          font_family = "$font";

          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
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
          "custom/pymodoro"
          "custom/notifications"
          "custom/vpn"
          "pulseaudio"
          "backlight"
          "battery"
          "clock"
        ];
        "hyprland/workspaces" = {
          format = "{icon}";
          "format-icons" = {
            "terminal" = "";
            "web" = "";
            "password" = "";
            "messenger" = "";
            "ai" = "";
          };
        };
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
        "custom/pymodoro" =
          let
            pymodoro-waybar = pkgs.writeShellScriptBin "pymodoro-waybar" ''
              PATH=${
                lib.makeBinPath [
                  pymodoro.packages.${pkgs.system}.default
                ]
              }
              case "$1" in
                status)
                  status=$(pd status --format '{remaining}')
                  percent=$(pd status --format '{percent}')
                  if [[ "$percent" == 'Inactive' ]]; then
                    icon=''
                  elif ((percent > 66)); then
                    icon=''
                  elif ((percent > 33 && percent <= 66)); then
                    icon=''
                  else
                    icon=''
                  fi
                  echo "{\"text\": \"$icon\", \"tooltip\": \"$status\"}"
                  ;;
                toggle)
                  if [[ "$(pd status)" == 'Inactive' ]]; then
                    pd start
                  else
                    pd stop
                  fi
              esac
            '';
          in
          {
            exec = "${pymodoro-waybar}/bin/pymodoro-waybar status";
            on-click = "${pymodoro-waybar}/bin/pymodoro-waybar toggle";
            interval = 1;
            return-type = "json";
          };
        "custom/notifications" =
          let
            dunstctl-waybar = pkgs.writeShellScriptBin "dunstctl-waybar" ''
              PATH=${
                lib.makeBinPath [
                  pkgs.dunst
                ]
              }

              if [[ "$(dunstctl is-paused)" == 'false' ]]; then
                echo ''
              else
                echo ''
              fi
            '';
          in
          {
            exec = "${dunstctl-waybar}/bin/dunstctl-waybar";
            on-click = "${pkgs.dunst}/bin/dunstctl set-paused toggle";
            interval = 1;
            tooltip = false;
          };
        "custom/vpn" =
          let
            eduvpn-cli-waybar = pkgs.writeShellScriptBin "eduvpn-cli-waybar" ''
              PATH=${
                lib.makeBinPath [
                  pkgs.coreutils
                  pkgs.eduvpn-client
                  pkgs.xdg-utils
                  pkgs.firefox
                ]
              }

              command=$1

              is_connected () {
                 output=$({ eduvpn-cli status 1> /dev/null; } 2>&1)
                 if [ "$output" = "You are currently not connected to a server" ]; then
                    echo 1
                 else
                    echo 0
                 fi
              }

              if [ "$command" = "status" ]; then
                 if [ $(is_connected) -eq 1 ]; then
                    echo ""
                 else
                    echo ""
                 fi
              elif [ "$command" = "toggle" ]; then
                 if [ $(is_connected) -eq 0 ]; then
                    eduvpn-cli disconnect
                 else
                    eduvpn-cli connect -n 1
                 fi
              else
                 echo "Error: Incorrect command supplied"
              fi
            '';
          in
          {
            exec = "${eduvpn-cli-waybar}/bin/eduvpn-cli-waybar status";
            interval = 1;
            on-click = "${eduvpn-cli-waybar}/bin/eduvpn-cli-waybar toggle";
            tooltip = false;
          };
        backlight = {
          format = "{percent}% ";
        };
        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            headset = "";
            default = [
              ""
              ""
            ];
          };
          on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
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
          format-alt = "{:%Y-%m-%d %H:%M}";
          tooltip = false;
        };
      };
    };
    style = ''
      * {
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: "monospace";
          font-size: 13px;
      }

      window#waybar {
          background-color: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      /*
      window#waybar.empty {
          background-color: transparent;
      }
      window#waybar.solo {
          background-color: #FFFFFF;
      }
      */

      window#waybar.termite {
          background-color: #3F3F3F;
      }

      window#waybar.chromium {
          background-color: #000000;
          border: none;
      }

      button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover {
          background: inherit;
          box-shadow: inset 0 -3px #ffffff;
      }

      /* you can set a style on hover for any module like this */
      #pulseaudio:hover {
          background-color: #a37800;
      }

      #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
      }

      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.focused, #workspaces button.active {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.urgent {
          background-color: #eb4d4b;
      }

      #mode {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #custom-pymodoro,
      #custom-notifications,
      #custom-vpn,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #power-profiles-daemon,
      #mpd {
          padding: 0 10px;
          color: #ffffff;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {
          background-color: #64727D;
      }

      #battery {
          background-color: #ffffff;
          color: #000000;
      }

      #battery.charging, #battery.plugged {
          color: #ffffff;
          background-color: #26A65B;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: #000000;
          }
      }

      /* Using steps() instead of linear as a timing function to limit cpu usage */
      #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #power-profiles-daemon {
          padding-right: 15px;
      }

      #power-profiles-daemon.performance {
          background-color: #f53c3c;
          color: #ffffff;
      }

      #power-profiles-daemon.balanced {
          background-color: #2980b9;
          color: #ffffff;
      }

      #power-profiles-daemon.power-saver {
          background-color: #2ecc71;
          color: #000000;
      }

      label:focus {
          background-color: #000000;
      }

      #custom-pymodoro {
          background-color: #bf2121;
      }

      #custom-notifications {
          background-color: #9b59b6;
      }

      #custom-vpn {
          background-color: #2ecc71;
          color: #000000;
      }

      #cpu {
          background-color: #2ecc71;
          color: #000000;
      }

      #memory {
          background-color: #9b59b6;
      }

      #disk {
          background-color: #964B00;
      }

      #backlight {
          background-color: #90b1b1;
      }

      #network {
          background-color: #2980b9;
      }

      #network.disconnected {
          background-color: #f53c3c;
      }

      #pulseaudio {
          background-color: #f1c40f;
          color: #000000;
      }

      #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
      }

      #wireplumber {
          background-color: #fff0f5;
          color: #000000;
      }

      #wireplumber.muted {
          background-color: #f53c3c;
      }

      #custom-media {
          background-color: #66cc99;
          color: #2a5c45;
          min-width: 100px;
      }

      #custom-media.custom-spotify {
          background-color: #66cc99;
      }

      #custom-media.custom-vlc {
          background-color: #ffa000;
      }

      #temperature {
          background-color: #f0932b;
      }

      #temperature.critical {
          background-color: #eb4d4b;
      }

      #tray {
          background-color: #2980b9;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }

      #idle_inhibitor {
          background-color: #2d3436;
      }

      #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
      }

      #mpd {
          background-color: #66cc99;
          color: #2a5c45;
      }

      #mpd.disconnected {
          background-color: #f53c3c;
      }

      #mpd.stopped {
          background-color: #90b1b1;
      }

      #mpd.paused {
          background-color: #51a37a;
      }

      #language {
          background: #00b093;
          color: #740864;
          padding: 0 5px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state {
          background: #97e1ad;
          color: #000000;
          padding: 0 0px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state > label {
          padding: 0 5px;
      }

      #keyboard-state > label.locked {
          background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad {
          background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad.empty {
      	background-color: transparent;
      }

      #privacy {
          padding: 0;
      }

      #privacy-item {
          padding: 0 5px;
          color: white;
      }

      #privacy-item.screenshare {
          background-color: #cf5700;
      }

      #privacy-item.audio-in {
          background-color: #1ca000;
      }

      #privacy-item.audio-out {
          background-color: #0069d4;
      }
    '';
  };

  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    profiles =
      let
        common = {
          "browser.in-content.dark-mode" = true;
          "ui.systemUsesDarkTheme" = 1;
          "browser.sessionstore.resume_from_crash" = false;
          "signon.rememberSignons" = false;
          "browser.translations.automaticallyPopup" = false;
          "browser.aboutConfig.showWarning" = false;
        };
      in
      {
        default = {
          id = 0;
          settings = common;
        };
        ai = {
          id = 1;
          settings = common // {
            "browser.startup.homepage" = "https://claude.ai";
          };
        };
      };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gtk2;
  };

  services.ssh-agent.enable = true;

  services.dunst.enable = true;

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
    jujutsu
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
