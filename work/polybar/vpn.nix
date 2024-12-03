{
  lib,
  writeShellScript,
  coreutils,
  eduvpn-client,
}:

writeShellScript "vpn.sh" ''
  PATH=${
    lib.makeBinPath [
      coreutils
      eduvpn-client
    ]
  }

  output=$(eduvpn-cli status 2>&1 > /dev/null)

  if [ "$output" = "You are currently not connected to a server" ]; then
          echo ""
  else
          echo "🔒"
  fi
''
