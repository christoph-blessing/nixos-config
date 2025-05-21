{
  lib,
  writeShellScript,
  coreutils,
  eduvpn-client,
  xdg-utils,
  firefox,
}:

writeShellScript "vpn.sh" ''
  PATH=${
    lib.makeBinPath [
      coreutils
      eduvpn-client
      xdg-utils
      firefox
    ]
  }

  command=$1

  is_connected () {
     output=$(eduvpn-cli status 2>&1 > /dev/null)
     if [ "$output" = "You are currently not connected to a server" ]; then
        echo 1
     else
        echo 0
     fi
  }

  if [ "$command" = "status" ]; then
     if [ $(is_connected) -eq 1 ]; then
        echo "🔓"
     else
        echo "🔒"
     fi
  elif [ "$command" = "toggle" ]; then
     if [ $(is_connected) -eq 0 ]; then
        eduvpn-cli disconnect
     else
        eduvpn-cli connect -n 1
     fi
  else
     echo "Error: Incorrect command supplied"
  fi
''
