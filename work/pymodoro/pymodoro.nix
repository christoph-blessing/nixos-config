{
  pkgs,
  lib,
  pymodoro,
  ...
}:
let
  pymodoroPkg = pymodoro.packages.${pkgs.system}.default;
  dunstPause = pkgs.writeShellScriptBin "dunstPause" ''
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
in
{
  home.packages = [ pymodoroPkg ];
  home.file.".config/pymodoro/config.toml".text = ''
    [pymodorod]
    begin_cmd = ["${dunstPause}/bin/dunstPause", "pause"]
    end_cmd = ["${dunstPause}/bin/dunstPause", "unpause"]
    done_cmd = ["${pkgs.alsa-utils}/bin/aplay", "${./school-bell.wav}"]

    [pymodoro]
    default_duration = "25m"
  '';
  systemd.user.services = {
    pymodoro = {
      Unit = {
        Description = "Pymodoro timer daemon";
      };
      Service = {
        ExecStart = "${pymodoroPkg}/bin/pymodorod";
      };
      Install = {
        WantedBy = [ "multi-user.target" ];
      };
    };
  };
  services.dunst.settings = {
    allow_pymodoro = {
      appname = "pymodoro";
      override_pause_level = 100;
    };
  };
  home.file.".config/polybar/pymodoro.sh" = {
    source = pkgs.writeShellScript "pymodoro.sh" ''
      PATH=${
        lib.makeBinPath [
          pymodoroPkg
        ]
      }
      echo "🍅 $(pymodoro)"
    '';
    executable = true;
  };
  services.polybar.settings = {
    "module/pymodoro" = {
      type = "custom/script";
      exec = "~/.config/polybar/pymodoro.sh";
      interval = 1;
    };
  };
}
