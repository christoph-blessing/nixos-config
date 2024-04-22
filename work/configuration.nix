{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../shared/configuration.nix
    ];

  networking.hostName = "nixe-work";
}
