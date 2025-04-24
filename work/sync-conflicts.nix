{ pkgs, ... }:

let
  inotifySend = pkgs.writeShellScriptBin "inotify-send" ''
    while true
    do
      conflict=$(${pkgs.inotify-tools}/bin/inotifywait --recursive --event create --include $2 --quiet --format '%w%f' $1)
      ${pkgs.libnotify}/bin/notify-send "Sync conflict: $conflict"
    done
  '';
in
{
  systemd.user.services = {
    watch-sync-conflicts = {
      Unit = {
        Description = "Watch for Syncthing file synchronization conflicts";
      };
      Service = {
        ExecStart = "${inotifySend}/bin/inotify-send /home/chris/Sync/ sync-conflict";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
