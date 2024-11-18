{
  lib,
  writeShellScript,
  pymodoroPkg,
}:

writeShellScript "pymodoro.sh" ''
  PATH=${
    lib.makeBinPath [
      pymodoroPkg
    ]
  }
  pymodoro
''
