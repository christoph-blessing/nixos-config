{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "chris";
  home.homeDirectory = "/home/chris";

  programs.git = {
    enable = true;
    userName = "Christoph Blessing";
    userEmail = "chris24.blessing@gmail.com";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ":luafile neovim/init.lua";
    plugins = with pkgs.vimPlugins; [
      vim-sleuth
      comment-nvim
      gitsigns-nvim
      which-key-nvim
      telescope-nvim
      nvim-lspconfig
      fidget-nvim
      neodev-nvim
      nvim-cmp
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      cmp-path
      tokyonight-nvim
      conform-nvim
      todo-comments-nvim
      mini-nvim
      nvim-treesitter.withAllGrammars
    ];
  };

  programs.nushell = {
    enable = true;
    configFile.source = nushell/config.nu;
    envFile.source = nushell/env.nu;
  };
  
  home.packages = with pkgs; [
    lua-language-server
    stylua
    ripgrep
  ];
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

