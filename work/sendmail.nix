{
  lib,
  writeShellScript,
  openssl,
  msmtp,
  coreutils,
  gnugrep,
}:

writeShellScript "sendmail.sh" ''
  PATH=${
    lib.makeBinPath [
      openssl
      msmtp
      coreutils
      gnugrep
    ]
  }

  message=$(cat)
  address=$(echo "$message" | grep -oP '^To:.*?<\K[^>]+')
  subject=$(echo "$message" | grep -oP '(?<=Subject: ).*$')
  echo "$message" | openssl smime -subject "$subject" -sign -signer /home/chris/.config/sops-nix/secrets/email/certificate | msmtp "$address";
''
