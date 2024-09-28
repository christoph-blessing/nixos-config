{ pkgs, lib, ... }:
let
  pymodoro = (
    pkgs.writeShellScriptBin "pymodoro" ''
      PATH=${lib.makeBinPath [ pkgs.python3 ]}

      python3 ${./pymodoro.py} "$@"
    ''
  );
  pymodorod = (
    pkgs.writeShellScriptBin "pymodorod" ''
      PATH=${
        lib.makeBinPath [
          pkgs.python3
          pkgs.alsa-utils
        ]
      }

      python3 ${./pymodorod.py} "$@"
    ''
  );
in
{
  home.packages = [ pymodoro ];
  systemd.user.services = {
    pymodoro = {
      Unit = {
        Description = "Pymodoro timer daemon";
      };
      Service = {
        ExecStart = "${pymodorod}/bin/pymodorod";
        Environment = [ "SOUND_PATH=${./school-bell.wav}" ];
      };
      Install = {
        WantedBy = [ "multi-user.target" ];
      };
    };
  };
}
