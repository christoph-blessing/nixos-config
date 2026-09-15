{ pkgs, ... }: {
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  hardware.printers = {
    ensureDefaultPrinter = "Office";
    ensurePrinters = [
      {
        name = "Office";
        location = "Third floor of computing center";
        deviceUri = "ipp://10.2.10.108/ipp/print";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions.PageSize = "A4";
      }
    ];
  };
}
