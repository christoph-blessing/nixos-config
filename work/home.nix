{ config, pkgs, ... }:

{
  imports = [ ../shared/home.nix ];

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
    hooks.postswitch.move_desktops = ''
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
  };

  home.packages = with pkgs; [ pavucontrol ];

  home.file.".config/polybar/vpn.sh" = {
    source = pkgs.callPackage ./polybar/vpn.nix { };
    executable = true;
  };

  services.polybar = {
    enable = true;
    script = "sleep 10; polybar mybar &";
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
        height = "2%";
        background = "\${colors.background}";
        foreground = "\${colors.foreground}";
        modules.left = "bspwm";
        modules.right = "cpu memory filesystem wireless-network vpn alsa battery date";
        module.margin = 1;
        separator = "|";
        override-redirect = false;
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
      "module/alsa" = {
        type = "internal/alsa";
        label = {
          volume = "VOL %percentage%%";
          muted = "Muted";
        };
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
