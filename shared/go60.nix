{ ... }: {
  fileSystems."/mnt/go60" = {
    device = "/dev/go60boot";
    fsType = "vfat";
    options = [
      "noauto"
      "nofail"
      "x-systemd.device-timeout=1s"
      "uid=1000"
      "gid=100"
      "umask=0022"
      "flush"
    ];
  };

  services.udev.extraRules = ''
    ACTION!="remove", SUBSYSTEM=="block", ENV{ID_SERIAL}=="*_GO60-*", SYMLINK+="go60boot", ENV{SYSTEMD_WANTS}+="mnt-go60.mount"
  '';
}
