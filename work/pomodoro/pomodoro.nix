{
  lib,
  writeShellScriptBin,
  coreutils,
  bash,
  alsa-utils,
}:
writeShellScriptBin "pomodoro" ''
  PATH=${
    lib.makeBinPath [
      alsa-utils
      coreutils
      bash
    ]
  }

  bash -c '
  seconds_left="$1"
  while true
  do
  	sleep 1
  	echo "$seconds_left"
  	seconds_left=$((seconds_left - 1))
  	if [ "$seconds_left" -eq 0 ]; then
  		break
  	fi
  done
  aplay ${./school-bell.wav}
  ' -- "$@" > /tmp/pomodoro.log 2>&1 &
''
