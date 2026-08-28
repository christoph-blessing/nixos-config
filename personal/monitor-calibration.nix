{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    argyllcms
    displaycal
  ];
  services.udev.packages = [
    (pkgs.writeTextDir "etc/udev/rules.d/55-spyder5.rules" ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="085c", ATTRS{idProduct}=="0500", TAG+="uaccess"
    '')
  ];
  services.colord.enable = true;
}
