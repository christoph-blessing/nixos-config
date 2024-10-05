{ pkgs, pymodoro, ... }:
let
  pymodoroPkg = pymodoro.packages.${pkgs.system}.default;
in
{
  home.packages = [ pymodoroPkg ];
  home.file.".config/pymodoro/config.toml".text = ''
    [pymodorod]
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
}
