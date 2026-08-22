{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./system-defaults.nix
    ./homebrew.nix
    ./fonts.nix
    ./security.nix
  ];

  # nix-darwin version of the state format, not macOS. Bump only after reading
  # the nix-darwin changelog.
  system.stateVersion = 7;

  # Makes /etc/zshrc source the nix environment so the (system) /bin/zsh login
  # shell sees /run/current-system/sw/bin and the per-user profile.
  programs.zsh = {
    enable = true;
    # home-manager runs compinit for the user; avoid doing it twice.
    enableCompletion = false;
  };

  # Tiny system-wide set; everything user-facing lives in home-manager.
  environment.systemPackages = with pkgs; [
    git
    curl
  ];
}
