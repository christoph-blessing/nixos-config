{ pkgs, ... }:

{
  imports = [ ../shared/home.nix ];

  accounts.email.accounts.gmail = {
    address = "chris24.blessing@gmail.com";
    primary = true;
    flavor = "gmail.com";
    himalaya.enable = true;
    mbsync = {
      enable = true;
      create = "both";
      expunge = "both";
      remove = "both";
    };
    msmtp.enable = true;
    passwordCommand = "gpg --quiet --for-your-eyes-only --no-tty --decrypt ${email/gmail-password.asc}";
    realName = "Christoph Blessing";
  };

  home.packages = with pkgs; [
    teamspeak_client
    ledger-live-desktop
    monero-cli
  ];
}
