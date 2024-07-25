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
            rev = "486984fc96991b9caa8ccd3437011abe605073c3";
            hash = "sha256-V1yWJGPgEtgUFJoqk0ZLAUKA3UyPb5NGnExkujKqE9o=";
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
