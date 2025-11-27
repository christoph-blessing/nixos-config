{
  config,
  pkgs,
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
    exec = "element-desktop --password-store=gnome-libsecret";
    type = "Application";
  };
}
