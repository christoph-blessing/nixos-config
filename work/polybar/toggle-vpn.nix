{
  lib,
  writeShellScript,
  coreutils,
  eduvpn-client,
}:

writeShellScript "toggle_vpn.sh" ''
  PATH=${
    lib.makeBinPath [
      coreutils
      eduvpn-client
    ]
  }

  output=$(DBUS_SESSION_BUS_ADDRESS= eduvpn-cli status 2>&1 > /dev/null | tail -n +2)

  if [ "$output" = "You are currently not connected to a server" ]; then
          eduvpn-cli connect -n 1
  else
          DBUS_SESSION_BUS_ADDRESS= eduvpn disconnect
  fi
''
