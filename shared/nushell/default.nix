{ lib, ... }:
{
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;

    # mkAfter so this lands after programs.carapace's `source …` line, which is
    # itself injected into programs.nushell.extraConfig at default priority.
    extraConfig = lib.mkAfter ''
      # Cobra binaries (restish, …) expose a hidden `__complete`; carapace has no
      # restish completer, so bridge it and fall through to carapace otherwise.
      let cobra_completer = {|spans|
        let out = (do -i { ^($spans | first) __complete ...($spans | skip 1) } | complete)
        if $out.exit_code != 0 { null } else {
          $out.stdout
          | lines
          | where {|l| ($l | str length) > 0 and not ($l | str starts-with ":") }
          | each {|l|
              let p = ($l | split row (char tab))
              {value: ($p | first), description: ($p | skip 1 | str join " ")}
            }
        }
      }

      let cobra_commands = ["restish"]
      let fallback_completer = $env.config.completions.external.completer

      $env.config.completions.external.completer = {|spans|
        if ($spans | first) in $cobra_commands {
          do $cobra_completer $spans
        } else {
          do $fallback_completer $spans
        }
      }
    '';
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };
}
