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
        set smime_sign_as = 0x2B071CC7
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
    46:C6:90:0A:77:3A:B6:BC:F4:65:AD:AC:FC:E3:F7:07:00:6E:DE:6E S
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
    nix-direnv.enable = true;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Font Awesome 7 Brands:style=Regular" ];
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

  services.kanshi =
    let
      arrangeWorkspaces = pkgs.writeShellScriptBin "arrange-workspaces" ''
        internal="AU Optronics 0xD7A4"
        monitor="''${1:-$internal}"

        if [[ "$monitor" != "$internal" ]]; then
          echo "Mirroring external monitor $monitor onto internal display $internal"
          hyprctl keyword monitor "eDP-1, preferred, auto, 1, mirror, desc:$monitor"
        else
          echo "Configuring internal display $internal"
          hyprctl keyword monitor "eDP-1, preferred, auto, 1"
        fi

        systemctl --user restart waybar

        workspaces=$(hyprctl workspaces -j | nix run nixpkgs#jq '.[].id' | sort -n)
        for ws in $workspaces; do
          echo "Moving workspace $ws to monitor $monitor"
          hyprctl dispatch moveworkspacetomonitor "$ws" "desc:$monitor"
        done
      '';
    in
    {
      enable = true;
      settings =
        let
          mkDockedProfile =
            { criteria }:
            {
              profile = {
                name = lib.toLower (builtins.replaceStrings [ " " ] [ "-" ] criteria);
                outputs = [
                  {
                    criteria = "AU Optronics 0xD7A4 Unknown";
                    status = "enable";
                  }
                  {
                    criteria = "${criteria}";
                    status = "enable";
                  }
                ];
                exec = "${arrangeWorkspaces}/bin/arrange-workspaces '${criteria}'";
              };
            };
        in
        [
          {
            profile = {
              name = "undocked";
              outputs = [
                {
                  criteria = "AU Optronics 0xD7A4 Unknown";
                  status = "enable";
                }
              ];
              exec = "${arrangeWorkspaces}/bin/arrange-workspaces";
            };
          }
          (mkDockedProfile {
            criteria = "Dell Inc. Dell U4919DW 4PFLXH3";
          })
          (mkDockedProfile {
            criteria = "Dell Inc. Dell U4919DW F5Y2VY2";
          })
          (mkDockedProfile {
            criteria = "Dell Inc. Dell U4919DW 9PS2VY2";
          })
          (mkDockedProfile {
            criteria = "Dell Inc. Dell U4919DW 17NWTY2";
          })
          (mkDockedProfile {
            criteria = "Dell Inc. Dell U4919DW 9CQXTY2";
          })
          (mkDockedProfile {
            criteria = "Dell Inc. Dell U4924DW 17LX0S3";
          })
          (mkDockedProfile {
            criteria = "Dell Inc. DELL U4025QW 5JXK734";
          })
        ];
    };

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
  xdg.desktopEntries."element-desktop" = {
    name = "Element";
    genericName = "Matrix Client";
    exec = "element-desktop --password-store=gnome-libsecret %u";
    type = "Application";
    mimeType = [
      "x-scheme-handler/element"
      "x-scheme-handler/io.element.desktop"
    ];
  };
}
