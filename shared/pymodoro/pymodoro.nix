{
  pkgs,
  lib,
  pymodoro,
  ...
}:
let
  pymodoroPkg = pymodoro.packages.${pkgs.system}.default;
  dunstPause = pkgs.writeShellScriptBin "dunst-pause" ''
    PATH=${lib.makeBinPath [ pkgs.dunst ]}

    if [[ "$1" == 'pause' ]]; then
      message='Notifications paused'
      is_paused='true'
    elif [[ "$1" == 'unpause' ]]; then
      message='Notifications unpaused'
      is_paused='false'
    else
      echo "Unknown parameter '$1'"
      exit 1
    fi

    dunstify --appname="pymodoro" "$message"
    dunstctl set-paused "$is_paused"
  '';
  pymodoroNotify = pkgs.writeShellScriptBin "pd-notify" ''
    PATH=${
      lib.makeBinPath [
        pkgs.alsa-utils
        pkgs.dunst
      ]
    }

    dunstify --appname="pymodoro" --urgency="critical" 'Take a break!'
    aplay '${./school-bell.wav}'
  '';
  configContents = ''
    [pymodorod]
    begin_cmd = ["${dunstPause}/bin/dunst-pause", "pause"]
    end_cmd = ["${dunstPause}/bin/dunst-pause", "unpause"]
    done_cmd = ["${pymodoroNotify}/bin/pd-notify"]

    [pymodoro]
    default_duration = "25m"
  '';
in
{
  home.packages = [ pymodoroPkg ];
  home.file.".config/pymodoro/config.toml".text = configContents;
  systemd.user.services = {
    pymodoro = {
      Unit = {
        Description = "Pymodoro timer daemon";
        X-Restart-Triggers = [ (builtins.hashString "sha256" configContents) ];
      };
      Service = {
        ExecStart = "${pymodoroPkg}/bin/pymodorod";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
  services.dunst.settings = {
    allow_pymodoro = {
      appname = "pymodoro";
      override_pause_level = 100;
    };
  };
}
