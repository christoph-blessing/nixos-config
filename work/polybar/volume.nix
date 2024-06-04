{
  lib,
  writeShellScript,
  polybar-pulseaudio-control,
  gnugrep,
  pulseaudio,
  gawk,
  gnused,
}:

writeShellScript "volume.sh" ''
  PATH=${
    lib.makeBinPath [
      polybar-pulseaudio-control
      gnugrep
      pulseaudio
      gawk
      gnused
    ]
  }
  pulseaudio-control "$@"
''
