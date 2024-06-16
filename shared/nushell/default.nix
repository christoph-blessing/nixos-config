{ pkgs, ... }:
{
  home.file.".config/nushell/completions" = {
    source = ./completions;
    recursive = true;
  };

  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    extraConfig = ''
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/git/git-completions.nu *
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/zellij/zellij-completions.nu *
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/nix/nix-completions.nu *
    '';
    envFile.source = ./env.nu;
  };
}
