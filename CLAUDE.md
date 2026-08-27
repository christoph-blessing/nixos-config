# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A NixOS flake managing two machines for a single user (`chris`):

- `nixe` — personal desktop (NVIDIA, Steam, Sunshine, Monero, NFS mounts) — `personal/`
- `nixe-work` — work laptop (LUKS root, NetworkManager, Docker, PipeWire, IPU6 webcam, mail) — `work/`

Both are built from `flake.nix`, which wires each host's `configuration.nix` together with Home Manager (as a NixOS module, `useGlobalPkgs`/`useUserPackages`), sops-nix, and the external `pymodoro` flake (passed through `home-manager.extraSpecialArgs`).

## Commands

```nu
# Rebuild (hostname matches the flake output, so `.#` can be omitted on the host itself)
sudo nixos-rebuild switch --flake .#nixe
sudo nixos-rebuild switch --flake .#nixe-work
sudo nixos-rebuild test --flake .        # try without adding a boot entry

nix flake check                          # runs the nixfmt pre-commit check
nix develop                              # devShell that installs the pre-commit hooks
nix flake update                         # bump inputs (commits named "update flake inputs")

sops secrets/secrets.yaml                # edit encrypted secrets
```

There are no tests. The only enforced check is `nixfmt` on `*.nix` (defined in `flake.nix` under `checks.pre-commit-check`); `.pre-commit-config.yaml` is a generated symlink into the Nix store — never edit it. Lua is formatted with `stylua` (available via neovim's `extraPackages`).

## Layout and the shared/host split

Every area follows the same pattern: a `shared/` module holds what both machines have, and each host imports it and layers host-specific options on top.

- `shared/configuration.nix` — system-level: boot, Hyprland + GDM, sops defaults, the `chris` user (password from sops, nushell as shell), syncthing, u2f PAM for login/sudo/hyprlock.
- `shared/home.nix` (~800 lines, the bulk of the config) — Home Manager: alacritty, git, neovim, zellij, wofi, hyprlock, waybar, firefox, dunst, direnv, gpg/ssh agents. Imports `shared/nushell/` and `shared/pymodoro/`.
- `personal/{configuration,home,hyprland,hypridle}.nix`, `work/{...}.nix` — host overlays. `work/` additionally has `mitmproxy.nix` (trusts a mitmproxy CA) and `work/keyboard/xkb_symbols`.

`hardware-configuration.nix` in each host dir is generator output — don't hand-edit.

### Config files kept outside Nix

Larger dotfiles live as plain files and are pulled in via `source`/`recursive` rather than being generated from Nix expressions. When changing editor/shell/WM behavior, edit these, not the `.nix`:

- `shared/neovim/` — whole dir is symlinked to `~/.config/nvim` (`xdg.configFile."nvim".recursive`). `lua/setup.lua` holds options/keymaps/LSP; `lua/plugins.lua` is a lazy.nvim spec. Plugins themselves are installed as Nix `vimPlugins`; lazy.nvim is pointed at the Home Manager pack dir (`lazy_dev_path`), so **adding a plugin means adding it to `programs.neovim.plugins` in `shared/home.nix` AND to `plugins.lua`**.
- `shared/nushell/{config.nu,env.nu}`, `shared/zellij/config.kdl`, `shared/keepassxc/keepassxc.ini`, `shared/scripts/oath.nu`.

### Hyprland

Hyprland uses `configType = "lua"`. `shared/hyprland.lua` is installed as `~/.config/hypr/shared.lua` and exports `M.mod` plus `M.main()` (common keybinds, gaps, window rules); host configs `require("shared")` and call `shared.main()`, then add monitors, workspace rules, and autostarts.

- `work/hyprland.nix` installs `work/hyprland.lua` as `hyprland.lua` and generates `paths.lua` with Nix store paths for the binaries the Lua launches (firefox profiles, keepassxc, element, alacritty) — add a `M.foo = "${pkg}/bin/foo"` line there before referencing it from Lua.
- `personal/hyprland.nix` instead inlines its config via `wayland.windowManager.hyprland.extraConfig`, so **`personal/hyprland.lua` is currently orphaned** (no `.nix` references it). Changes to personal Hyprland config must go in `personal/hyprland.nix`.

### Secrets

`secrets/secrets.yaml` is sops-encrypted to two age recipients (one per host, listed in `.sops.yaml`); the private key is expected at `~/.config/sops/age/keys.txt`. Declaring `sops.secrets."path/name" = { };` makes it appear at `/run/secrets/path/name`. sops runs at both levels: the NixOS module (`shared/configuration.nix`, `work/configuration.nix` for wifi PSKs via NetworkManager `environmentFiles`) and the Home Manager module (`work/home.nix` for the mail password and signature). Reference secrets via `config.sops.secrets."...".path` in Home Manager rather than hardcoding `/run/secrets`.

### Unfree packages

There is no global `allowUnfree`. Each host uses an explicit `nixpkgs.config.allowUnfreePredicate` allowlist keyed on `lib.getName` — a new unfree package needs its name added there or the build fails.

## Repo conventions

- The repo is a jj (jujutsu) working copy colocated with git — `.jj/` is present and `jujutsu` is installed. Either CLI works; `git` output reflects jj's commits.
- Commit messages are lowercase imperative, one line, no scope prefix (`add kanshi profile`, `fix compose setup`, `update flake inputs`).
- The stray NixOS boilerplate comment blocks in `shared/configuration.nix` are intentional leftovers from `nixos-generate-config`; leave them alone.
