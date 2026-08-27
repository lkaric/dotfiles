{ pkgs, user, ... }:
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

  # home.sessionVariables only reaches processes descended from a zsh that
  # sourced .zshenv. GUI apps launched from the Dock or Finder do not qualify,
  # and Zed spawns `omp acp` as a child of the app bundle -- without this the
  # ACP agent would run with no policy overlay. launchctl setenv covers both,
  # and matters more now that programs.omp.settings overwrites config.yml
  # wholesale on every switch (the overlay carries what it omits).
  launchd.user.envVariables.PI_CONFIG_FILES = "${user.dotfiles}/config/omp/settings.yml";

  # Tiny system-wide set; everything user-facing lives in home-manager.
  environment.systemPackages = with pkgs; [
    git
    curl
  ];
}
