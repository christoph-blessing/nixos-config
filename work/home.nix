{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./pymodoro/pymodoro.nix
    ./sync-conflicts.nix
    ../shared/home.nix
  ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/chris/.config/sops/age/keys.txt";
    secrets = {
      "email/password" = { };
      "email/signature.txt" = { };
      "email/aliases" = { };
    };
  };

  accounts.email.accounts.work = {
    address = "christophbenjamin.blessing@gwdg.de";
    primary = true;
    passwordCommand =
      let
        passwordScript = pkgs.writeShellScript "passsword_script.sh" ''
          ${pkgs.coreutils}/bin/cat ${config.sops.secrets."email/password".path}
        '';
      in
      "${passwordScript}";
    userName = "cblessi";
    realName = "Christoph Benjamin Blessing";
    signature = {
      command = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."email/signature.txt".path}";
      showSignature = "append";
    };
    imap = {
      host = "email.gwdg.de";
      port = 993;
      tls = {
        enable = true;
      };
    };
    imapnotify = {
      enable = true;
      boxes = [ "INBOX" ];
      onNotify = "${pkgs.isync}/bin/mbsync work";
      onNotifyPost = "${pkgs.libnotify}/bin/notify-send 'New mail arrived'";
    };
    mbsync = {
      enable = true;
      extraConfig.account = {
        AuthMechs = [ "LOGIN" ];
      };
      create = "maildir";
      expunge = "both";
      patterns = [
        "INBOX"
        "Drafts"
        "Sent Items"
        "Deleted Items"
      ];
    };
    smtp = {
      host = "email.gwdg.de";
      port = 587;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };
    msmtp.enable = true;
    neomutt = {
      enable = true;
      extraMailboxes = [
        "Drafts"
        "Sent Items"
        "Deleted Items"
      ];
      extraConfig = ''
        set smime_sign_as = 0x56BD7EFC
        set crypt_auto_sign = yes
        set smime_is_default = yes
        set record = "+Sent Items"
        set trash = "+Deleted Items"
        source ${config.sops.secrets."email/aliases".path}
      '';
    };
  };

  services.imapnotify.enable = true;
  services.dunst.enable = true;

  home.file.".gnupg/gpgsm.conf".text = ''
    disable-crl-checks
  '';

  home.file.".gnupg/trustlist.txt".text = ''
    D1:EB:23:A4:6D:17:D6:8F:D9:25:64:C2:F1:F1:60:17:64:D8:E3:49 S
  '';

  programs.neomutt = {
    enable = true;
    extraConfig = ''
      set crypt_use_gpgme
      set abort_key = "<Esc>"
    '';
  };
  home.sessionVariables = {
    ESCDELAY = "0";
  };

  home.file.".mailcap".text = with pkgs; ''
    text/html; ${firefox}/bin/firefox --new-window %s
    application/pdf; ${firefox}/bin/firefox --new-window %s
    image/png; ${feh}/bin/feh %s
    application/vnd.openxmlformats-officedocument.presentationml.presentation; ${libreoffice}/bin/libreoffice --impress %s
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; ${libreoffice}/bin/libreoffice --calc %s
  '';

  programs.nushell.extraEnv = ''
    $env.PATH = ($env.PATH | split row (char esep) | prepend '/home/chris/.config/guix/current/bin')
  '';

  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
  };

  xsession.windowManager.bspwm = {
    monitors = {
      eDP-1 = [
        "I"
        "II"
        "III"
        "IV"
      ];
    };
    extraConfig = ''
      bspc node @I:/ --insert-receptacle
      bspc rule --add Alacritty --one-shot node=@I:/
      bspc node @II:/ --insert-receptacle
      bspc rule --add firefox --one-shot node=@II:/
      bspc node @III:/ --insert-receptacle
      bspc rule --add KeePassXC --one-shot node=@III:/
      bspc node @IV:/ --insert-receptacle
      bspc rule --add Element --one-shot node=@IV:/
      autorandr --ignore-lid --change
    '';
    startupPrograms = [
      "alacritty"
      "firefox"
      "keepassxc"
      "element-desktop"
    ];
  };

  services.sxhkd = {
    enable = true;
    keybindings = {
      "XF86AudioMute" = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioLowerVolume" = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioRaiseVolume" = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioMicMute" = "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
    };
  };

  services.autorandr.enable = true;
  programs.autorandr =
    let
      set-up-monitor = pkgs.writeShellScriptBin "set-up-monitor" ''
        PATH=${
          lib.makeBinPath [
            pkgs.toybox
            pkgs.bspwm
            pkgs.systemd
          ]
        }

        set -e
        echo "setting up monitor..."

        current_profile=$AUTORANDR_CURRENT_PROFILE

        previous_profile=
        if [ -f "/tmp/autorandr_current_profile" ]; then
          previous_profile="$(cat /tmp/autorandr_current_profile)"
        fi

        echo "previous profile: $previous_profile" 
        echo "current profile: $current_profile" 

        if [ -n "$previous_profile" ] && [ "$previous_profile" = "$current_profile" ]; then
          echo "exiting: No profile change" 
          exit
        else 
          echo "profile change: $previous_profile -> $current_profile"
        fi

        echo "stopping polybar service"
        systemctl --user stop polybar.service
        echo "stopped polybar service"

        echo "moving desktops"
        target=$AUTORANDR_MONITORS
        monitors=$(bspc query -M --names)
        for source in $monitors; do
          if [ "$source" = "$target" ]; then
            continue
          fi
          desktops=$(bspc query -D --names --monitor $source)
          bspc monitor $source --add-desktops temp
          for desktop in $desktops; do
            bspc desktop $desktop --to-monitor $target
          done
          bspc monitor $source --remove
        done
        bspc desktop Desktop --remove
        echo "finished moving desktops"

        echo "starting polybar service" 
        systemctl --user start polybar.service
        sleep 1 # Wait for polybar to initialize
        echo "started polybar service" 

        # Force bspwm to update desktops to prevent polybar behing drawn behind other windows
        echo "updating desktops"
        bspc query -D | while read -r desktop; do
          bspc config -d "$desktop" top_padding 0
          bspc config -d "$desktop" right_padding 0
          bspc config -d "$desktop" bottom_padding 0
          bspc config -d "$desktop" left_padding 0
        done
        echo "finished updating desktops"

        echo $AUTORANDR_CURRENT_PROFILE > /tmp/autorandr_current_profile
        echo "finished monitor setup"
      '';
    in
    {
      enable = true;
      hooks.postswitch.set-up-monitor = "${set-up-monitor}/bin/set-up-monitor";
      profiles.mobile = {
        fingerprint = {
          "eDP-1" =
            "00ffffffffffff0006afa4d70000000031200104a51d127803eac5a6544a9a2412505400000001010101010101010101010101010101fa3c80b870b0244010103e001eb21000001ac83080b870b0244010103e001eb21000001a000000fe005630395854804231333355414b00000000000241029e001200000a410a20200037";
        };
        config = {
          "eDP-1" = {
            enable = true;
            primary = true;
            mode = "1920x1200";
            rate = "60";
          };
        };
      };
      profiles.office = {
        fingerprint = {
          "eDP-1" =
            "00ffffffffffff0006afa4d70000000031200104a51d127803eac5a6544a9a2412505400000001010101010101010101010101010101fa3c80b870b0244010103e001eb21000001ac83080b870b0244010103e001eb21000001a000000fe005630395854804231333355414b00000000000241029e001200000a410a20200037";
          "DP-1-3" =
            "00ffffffffffff0010ac24d1563336310e20010380502178ea19f5aa4d43aa24105054a54b00714f8140818081c081009500b300d1c0e77c70a0d0a0295030203a001d4e3100001a000000ff004a3644575336330a2020202020000000fc0044454c4c205333343232445747000000fd0030781dc83c000a202020202020011f020353f1550102030711121613042f4647141f05103f4c4e60612309070783010000e200d567030c001000183c67d85dc4017888016d1a000002033078e6076c2c6c2ce305c000e40f000038e60605016c6c2c4ed470a0d0a0465030203a001d4e3100001a6fc200a0a0a05550302035001d4e3100001a000000000000000033";
        };
        config = {
          "eDP-1".enable = false;
          "DP-1-3" = {
            enable = true;
            primary = true;
            mode = "3440x1440";
            rate = "60";
          };
        };
      };
      profiles.home = {
        fingerprint = {
          "eDP-1" =
            "00ffffffffffff0006afa4d70000000031200104a51d127803eac5a6544a9a2412505400000001010101010101010101010101010101fa3c80b870b0244010103e001eb21000001ac83080b870b0244010103e001eb21000001a000000fe005630395854804231333355414b00000000000241029e001200000a410a20200037";
          "DP-1" =
            "00ffffffffffff004c2d537055385843001e0104b57722783bc725b14b46a8260e5054bfef80714f810081c08180a9c0b3009500d1c074d600a0f038404030203a00a9504100001a000000fd003c78b7b761010a202020202020000000fc004c433439473935540a20202020000000ff0048345a4e3730303336390a202002ef02032df044105a3f5c2309070783010000e305c0006d1a0000020f3c7800048b127317e3060501e5018b849001565e00a0a0a0295030203500a9504100001a584d00b8a1381440f82c4500a9504100001e1a6800a0f0381f4030203a00a9504100001a6fc200a0a0a0555030203500a9504100001a00000000000000000000fc00ffffffffffff004a8bbf01010050630c140104b5301b783a3585a656489a24125054b30c00714f810081809500d1c0010101010101023a801871382d40582c4500dd0c1100001e000000fd00384b1e5311000a202020202020000000fc0052544b204648440a2020202020000000ff004c35363035313739343330320a0197";
        };
        config = {
          "eDP-1".enable = false;
          "DP-1" = {
            enable = true;
            primary = true;
            mode = "5120x1440_60.00";
          };
        };
      };
    };

  services.polybar =
    let
      pulseaudio-control = pkgs.callPackage ./polybar/pulseaudio-control.nix { };
    in
    {
      enable = true;
      script = "polybar mybar &";
      settings = {
        "colors" = {
          background = "#282A2E";
          background-alt = "#373B41";
          foreground = "#C5C8C6";
          primary = "#F0C674";
          secondary = "#8ABEB7";
          alert = "#A54242";
          disabled = "#707880";
        };
        "bar/mybar" = {
          width = "100%";
          background = "\${colors.background}";
          foreground = "\${colors.foreground}";
          font-0 = "monospace";
          font-1 = "emoji:pixelsize=16:style=Regular:scale=10;1";
          modules.left = "bspwm";
          modules.right = "cpu memory filesystem wired-network wireless-network vpn pymodoro notifications volume microphone backlight battery date";
          module.margin = 1;
          separator = "|";
          wm.restack = "bspwm";
        };
        "module/bspwm" = {
          type = "internal/bspwm";
          enable.click = false;
          enable.scroll = false;
          label.focused.background = "\${colors.background-alt}";
        };
        "module/cpu" = {
          type = "internal/cpu";
          format.prefix = "💻 ";
        };
        "module/memory" = {
          type = "internal/memory";
          format.prefix = "💾 ";
        };
        "module/wired-network" = {
          type = "internal/network";
          interface = "enp0s13f0u3u4u4";
          label = {
            connected = "%ifname% %netspeed:9%";
            disconnected = "not connected";
          };
        };
        "module/wireless-network" = {
          type = "internal/network";
          interface = "wlp86s0f0";
          label = {
            connected = "📡 %essid% %netspeed:9%";
            disconnected = "📡 🚫";
          };
        };
        "module/filesystem" = {
          type = "internal/fs";
          label.mounted = "%mountpoint% %percentage_used%%";
        };
        "module/volume" = {
          type = "custom/script";
          exec = "${pulseaudio-control} --format '$VOL_ICON $NODE_NICKNAME' --node-nickname 'alsa_output.pci-0000_00_1f.3.analog-stereo:💻' --node-nickname 'bluez_output.AC_80_0A_A4_4E_06.1:🎧' --node-nickname 'bluez_output.94_DB_56_4F_46_F9.1:🎧' --icon-muted 🔇 --icons-volume 🔈,🔉,🔊 listen";
          tail = true;
          click-left = "${pulseaudio-control} togmute";
          click-right = "exec ${pkgs.pavucontrol}/bin/pavucontrol &";
          scroll-up = "${pulseaudio-control} --volume-max 100 up";
          scroll-down = "${pulseaudio-control} --volume-max 100 down";
        };
        "module/microphone" = {
          type = "custom/script";
          exec = "${pulseaudio-control} --node-type input --format '$VOL_ICON $ICON_NODE' --icon-node 🎤 --icon-muted 🔇 --icons-volume 🔈,🔉,🔊 listen";
          tail = true;
          click-left = "${pulseaudio-control} --node-type input togmute";
          scroll-up = "${pulseaudio-control} --node-type input --volume-max 100 up";
          scroll-down = "${pulseaudio-control} --node-type input --volume-max 100 down";
        };
        "module/battery" = {
          type = "internal/battery";
          label = {
            charging = "🔌 %percentage%%";
            discharging = "🔋 %percentage%%";
            full = "🔋";
            low = "🪫";
          };
        };
        "module/date" = {
          type = "internal/date";
          interval = 1;
          date = "%Y-%m-%d %H:%M";
          label = "%date%";
        };
        "module/vpn" =
          let
            eduvpn = pkgs.callPackage ./polybar/eduvpn.nix { };
          in
          {
            type = "custom/script";
            exec = "${eduvpn} status";
            click-left = "${eduvpn} toggle";
            label = "%output%";
            interval = 1;
          };
        "module/backlight" = {
          type = "internal/backlight";
          enable-scroll = true;
          use-actual-brightness = false;
          label = "🔆 %percentage%%";
        };
        "module/notifications" =
          let
            notificationsScript = (
              pkgs.writeShellScriptBin "notifications" ''
                PATH=${
                  lib.makeBinPath [
                    pkgs.dunst
                  ]
                }

                get_status () {
                  is_paused=$(dunstctl is-paused)
                  if [ "$is_paused" == 'true' ]; then
                     echo '🔕'
                  else
                     echo '🔔'
                  fi
                }

                toggle() {
                  dunstctl set-paused toggle
                }

                command=$1

                if [ "$command" == 'status' ]; then
                  echo $(get_status)
                elif [ "$command" == 'toggle' ]; then
                  toggle
                fi
              ''
            );
          in
          {
            type = "custom/script";
            exec = "${notificationsScript}/bin/notifications status";
            click-left = "${notificationsScript}/bin/notifications toggle";
            label = "%output%";
            interval = 1;
          };
      };
    };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Noto Color Emoji:style=Regular" ];
      monospace = [ "JetBrainsMono Nerd Font,JetBrainsMono NF:style=Regular" ];
    };
  };

  home.packages = with pkgs; [
    (writeShellScriptBin "reboot" ''
      if [[ "$(realpath /run/current-system/)" != "$(realpath /nix/var/nix/profiles/system/)" ]]; then
         read -p "Current config will not be booted! Continue? y/n " answer
         if [[ "$answer" != 'y' ]]; then
            echo "Aborting"
            exit
         fi
      fi

      echo 'Rebooting'
      ${pkgs.systemd}/bin/systemctl reboot
    '')
  ];

  programs.element-desktop = {
    enable = true;
    settings = {
      default_server_config = {
        "m.homeserver" = {
          base_url = "https://matrix.gwdg.de/";
          server_name = "matrix.gwdg.de";
        };
        "m.identity_sever" = {
          base_url = "";
        };
      };
      default_theme = "dark";
    };
  };
}
