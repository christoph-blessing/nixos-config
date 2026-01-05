{
  pkgs,
  config,
  lib,
  pymodoro,
  ...
}:

{
  imports = [ ./nushell ];

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
    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "AU Optronics 0xD7A4 Unknown";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "AU Optronics 0xD7A4 Unknown";
            status = "disable";
          }
          {
            criteria = "Dell Inc. DELL S3422DWG J6DWS63";
            status = "enable";
          }
        ];
      }
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,auto";
      "$terminal" = "alacritty";
      "$menu" = "wofi --show drun";
      exec-once = with pkgs; [
        "[workspace 1] ${alacritty}/bin/alacritty"
        "[workspace 2 silent] ${firefox}/bin/firefox -P default"
        "[workspace 3 silent] ${firefox}/bin/firefox -P perplexity"
        "[workspace 4 silent] ${keepassxc}/bin/keepassxc"
        "[workspace 5 silent] ${firefox}/bin/firefox -P element"
        "${killall}/bin/killall waybar; waybar"
        "${zellij}/bin/zellij kill-all-sessions --yes"
        "${hypridle}/bin/hypridle"
      ];
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/ssh-agent"
      ];
      general = {
        gaps_in = 0;
        gaps_out = 0;
      };
      animations = {
        enabled = false;
      };
      "$mainMod" = "SUPER";
      input = {
        kb_layout = "us";
        kb_model = "pc105";
        kb_options = "compose:menu";
        touchpad = {
          natural_scroll = true;
        };
      };
      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod, L, exec, hyprlock"
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
      bindl =
        let
          lidctl = pkgs.writeShellScriptBin "lidctl" ''
            PATH=${
              lib.makeBinPath [
                pkgs.hyprland
                pkgs.ripgrep
                pkgs.systemd
              ]
            }

            hyprctl monitors | rg -q ' DP-'
            external_display_connected=$?

            if [ "$external_display_connected" -eq 1 ]; then
              loginctl lock-session
            fi
          '';
        in
        [
          ",switch:Lid Switch,exec,${lidctl}/bin/lidctl"
        ];
      workspace = [
        "1,defaultName:terminal"
        "2,defaultName:web"
        "3,defaultName:ai"
        "4,defaultName:password"
        "5,defaultName:messenger"
      ];
      windowrule = [
        "suppress_event maximize, match:class .*"
        "no_initial_focus on,match:class ^$,match:title ^$,match:xwayland 1,match:float 1,match:fullscreen 0,match:pin 0"
        "move onscreen cursor, match:title ^(menu window)$, match:class ^(zoom)$"
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pkgs.toybox}/bin/pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
      };
      listener =
        let
          displayctl = pkgs.writeShellScriptBin "displayctl" ''
            PATH=${
              lib.makeBinPath [
                pkgs.coreutils
                pkgs.hyprland
                pkgs.brightnessctl
              ]
            }

            should_be_plugged_in=$1
            action=$2

            if [ $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/AC/online) -eq "$should_be_plugged_in" ]; then
              if [ "$action" = "timeout" ]; then
                hyprctl dispatch dpms off
              else
                hyprctl dispatch dpms on && brightnessctl -r
              fi
            fi
          '';
        in
        [
          {
            timeout = 270;
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
          }
          {
            timeout = 300;
            on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
          }
          {
            timeout = 330;
            on-timeout = "${displayctl}/bin/displayctl 0 timeout";
            on-resume = "${displayctl}/bin/displayctl 0 resume";
          }
          {
            timeout = 600;
            on-timeout = "${displayctl}/bin/displayctl 1 timeout";
            on-resume = "${displayctl}/bin/displayctl 1 resume";
          }
        ];
    };
  };

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
                 output=$(eduvpn-cli status 2>&1 > /dev/null)
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
          format-alt = "{:%Y-%m-%d}";
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
        perplexity = {
          id = 1;
          settings = common // {
            "browser.startup.homepage" = "https://perplexity.com";
          };
        };
        element = {
          id = 2;
          settings = common // {
            "browser.startup.homepage" = "https://app.element.io/";
          };
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
