{ pkgs, ... }:
{
  home.file.".config/nushell/completions" = {
    source = ./completions;
    recursive = true;
  };

  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    extraConfig =
      let
        my_nu_scripts = pkgs.nu_scripts.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            owner = "christoph-blessing";
            repo = old.src.repo;
            rev = "f6fd4ae6f56122d01e378ef1a618e5cb898d1bdb";
            hash = "sha256-eVPWCfQdleV+bVoGQMS6tNVFHHexakj9M6cO4/w1p8g=";
          };
        });
      in
      ''
        use ${my_nu_scripts}/share/nu_scripts/custom-completions/git/git-completions.nu *
        use ${my_nu_scripts}/share/nu_scripts/custom-completions/zellij/zellij-completions.nu *
        use ${my_nu_scripts}/share/nu_scripts/custom-completions/nix/nix-completions.nu *
        use ${my_nu_scripts}/share/nu_scripts/custom-completions/rg/rg-completions.nu *
        use ${my_nu_scripts}/share/nu_scripts/custom-completions/man/man-completions.nu *
        use ${my_nu_scripts}/share/nu_scripts/custom-completions/docker/docker-completions.nu *
      '';
    envFile.source = ./env.nu;
  };
}
