{ config, pkgs, ... }:

{
  imports = [ ../shared/home.nix ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/chris/.config/sops/age/keys.txt";
    secrets = {
      "email/password" = { };
    };
  };

  services.mbsync = {
    enable = true;
  };
  systemd.user.services.mbsync.Unit.After = [ "sops-nix.service" ];

  accounts.email.accounts.work = {
    address = "christophbenjamin.blessing@gwdg.de";
    primary = true;
    passwordCommand = "${pkgs.coreutils}/bin/cat ~/.config/sops-nix/secrets/email/password";
    userName = "cblessi";
    realName = "Christoph Blessing";
    imap = {
      host = "email.gwdg.de";
      port = 993;
      tls = {
        enable = true;
      };
    };
    mbsync = {
      enable = true;
      extraConfig.account = {
        AuthMechs = [ "LOGIN" ];
      };
      create = "maildir";
      patterns = [
        "INBOX"
        "Drafts"
        "Sent Items"
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
    himalaya.enable = true;
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
      autorandr --ignore-lid --change
    '';
    startupPrograms = [
      "alacritty"
      "firefox"
      "keepassxc"
    ];
  };

  programs.autorandr = {
    enable = true;
    hooks.postswitch.set-up-monitor = ''
      if [ -f "/tmp/autorandr_current_profile" ]; then
        previous_profile=$(cat /tmp/autorandr_current_profile)
        if [ $previous_profile == $AUTORANDR_CURRENT_PROFILE ]; then
          exit
        fi
      fi

      target=$AUTORANDR_MONITORS
      monitors=$(bspc query -M --names)
      for source in $monitors; do
        if [ $source == $target ]; then
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

      pkill -x polybar
      polybar -q mybar &

      echo $AUTORANDR_CURRENT_PROFILE > /tmp/autorandr_current_profile
    '';
    profiles.mobile = {
      fingerprint = {
        "e-DP1" = "00ffffffffffff000daed013000000000f210104a51d127803ee95a3544c99260f505400000001010101010101010101010101010101743c80a070b028403020a6001eb21000001a000000fd00303c4a4a0f010a202020202020000000fe003233575657803133334a43470a0000000000024101a8000000000a410a202000a0";
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
        "e-DP1" = "00ffffffffffff000daed013000000000f210104a51d127803ee95a3544c99260f505400000001010101010101010101010101010101743c80a070b028403020a6001eb21000001a000000fd00303c4a4a0f010a202020202020000000fe003233575657803133334a43470a0000000000024101a8000000000a410a202000a0";
        "DP-1-3" = "00ffffffffffff0010ac24d1563336310e20010380502178ea19f5aa4d43aa24105054a54b00714f8140818081c081009500b300d1c0e77c70a0d0a0295030203a001d4e3100001a000000ff004a3644575336330a2020202020000000fc0044454c4c205333343232445747000000fd0030781dc83c000a202020202020011f020353f1550102030711121613042f4647141f05103f4c4e60612309070783010000e200d567030c001000183c67d85dc4017888016d1a000002033078e6076c2c6c2ce305c000e40f000038e60605016c6c2c4ed470a0d0a0465030203a001d4e3100001a6fc200a0a0a05550302035001d4e3100001a000000000000000033";
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
        "e-DP1" = "00ffffffffffff000daed013000000000f210104a51d127803ee95a3544c99260f505400000001010101010101010101010101010101743c80a070b028403020a6001eb21000001a000000fd00303c4a4a0f010a202020202020000000fe003233575657803133334a43470a0000000000024101a8000000000a410a202000a0";
        "DP-1" = "00ffffffffffff004c2d537055385843001e0104b57722783bc725b14b46a8260e5054bfef80714f810081c08180a9c0b3009500d1c074d600a0f038404030203a00a9504100001a000000fd003c78b7b761010a202020202020000000fc004c433439473935540a20202020000000ff0048345a4e3730303336390a202002ef02032df044105a3f5c2309070783010000e305c0006d1a0000020f3c7800048b127317e3060501e5018b849001565e00a0a0a0295030203500a9504100001a584d00b8a1381440f82c4500a9504100001e1a6800a0f0381f4030203a00a9504100001a6fc200a0a0a0555030203500a9504100001a00000000000000000000fc00ffffffffffff004a8bbf01010050630c140104b5301b783a3585a656489a24125054b30c00714f810081809500d1c0010101010101023a801871382d40582c4500dd0c1100001e000000fd00384b1e5311000a202020202020000000fc0052544b204648440a2020202020000000ff004c35363035313739343330320a0197";
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

  home.file.".config/polybar/vpn.sh" = {
    source = pkgs.callPackage ./polybar/vpn.nix { };
    executable = true;
  };

  home.file.".config/polybar/volume.sh" = {
    source = pkgs.callPackage ./polybar/volume.nix { };
    executable = true;
  };

  services.polybar = {
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
        modules.left = "bspwm";
        modules.right = "cpu memory filesystem wireless-network vpn volume battery date";
        module.margin = 1;
        separator = "|";
      };
      "module/bspwm" = {
        type = "internal/bspwm";
        enable.click = false;
        enable.scroll = false;
        label.focused.background = "\${colors.background-alt}";
      };
      "module/cpu" = {
        type = "internal/cpu";
        format.prefix = "CPU ";
      };
      "module/memory" = {
        type = "internal/memory";
        format.prefix = "RAM ";
      };
      "module/wireless-network" = {
        type = "internal/network";
        interface = "wlp0s20f3";
        label = {
          connected = "WIFI %essid% %downspeed:9%";
          disconnected = "WIFI not connected";
        };
      };
      "module/filesystem" = {
        type = "internal/fs";
        label.mounted = "%mountpoint% %percentage_used%%";
      };
      "module/volume" = {
        type = "custom/script";
        exec = "~/.config/polybar/volume.sh --node-nickname 'alsa_output.pci-0000_00_1f.3.analog-stereo: Speakers' --node-nickname 'bluez_output.AC_80_0A_A4_4E_06.1: Headphones' listen";
        tail = true;
        click-left = "~/.config/polybar/volume.sh togmute";
        click-right = "exec ${pkgs.pavucontrol}/bin/pavucontrol &";
        scroll-up = "~/.config/polybar/volume.sh --volume-max 130 up";
        scroll-down = "~/.config/polybar/volume.sh --volume-max 130 down";
      };
      "module/battery" = {
        type = "internal/battery";
        label = {
          charging = "Charging %percentage%%";
          discharging = "Discharging %percentage%%";
          full = "Fully charged";
          low = "BATTERY LOW";
        };
      };
      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%H:%M";
        date-alt = "%Y-%m-%d %H:%M";
        label = "%date%";
      };
      "module/vpn" = {
        type = "custom/script";
        exec = "~/.config/polybar/vpn.sh";
        label = "VPN %output%";
        interval = 5;
      };
    };
  };
}
