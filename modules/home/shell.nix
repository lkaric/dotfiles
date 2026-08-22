{
  pkgs,
  user,
  host,
  ...
}:
let
  dots = user.dotfiles;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # sheldon provides autosuggestions + syntax highlighting (see
    # config/sheldon/plugins.toml), so the HM variants stay off.
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

    history = {
      size = 100000;
      save = 100000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    shellAliases = {
      # nix-darwin lifecycle
      nrs = "sudo darwin-rebuild switch --flake ${dots}#${host.name}";
      nup = "(cd ${dots} && nix flake update && sudo darwin-rebuild switch --flake ${dots}#${host.name} && brew update && brew upgrade)";
      ncg = "sudo nix-collect-garbage --delete-older-than 14d && nix store optimise";
      nfmt = "(cd ${dots} && nix fmt)";
      dots = "cd ${dots}";
    };

    # Mutable extras: anything in config/zsh/*.zsh is sourced, no rebuild.
    initContent = ''
      for f in ${dots}/config/zsh/*.zsh(N); do
        source "$f"
      done
    '';
  };

  # Plugin manager; plugins.toml is ours (config/sheldon), HM only adds the
  # `eval "$(sheldon source)"` hook.
  programs.sheldon = {
    enable = true;
    enableZshIntegration = true;
  };

  # Prompt; starship.toml is ours (config/starship.toml).
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Shell history; config.toml is ours (config/atuin/config.toml).
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
  };

  # eza as ls: HM defines ls/ll/la/lt/lla aliases.
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  # Runtime manager; config.toml is ours (config/mise/config.toml).
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };

  # gh: package only. ~/.config/gh stays mutable because gh rewrites it
  # (two accounts: `gh auth switch`).
  home.packages = [ pkgs.gh ];
}
