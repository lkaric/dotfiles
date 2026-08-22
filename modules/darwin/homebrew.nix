{ user, ... }:
{
  # nix-homebrew installs/adopts Homebrew itself (autoMigrate takes over the
  # existing /opt/homebrew). Packages are declared below via nix-darwin.
  nix-homebrew = {
    enable = true;
    user = user.name;
    autoMigrate = true;
    # Third-party taps need explicit trust on Homebrew >= 4.6.
    trust.taps = [ "supercmdlabs/supercmd" ];
  };

  homebrew = {
    enable = true;

    onActivation = {
      # Keep `nrs` fast: no brew update/upgrade on every switch. `nup` does it.
      autoUpdate = false;
      upgrade = false;
      # "none" while migrating; flip to "zap" once the declared set is final
      # so anything undeclared is uninstalled (and stays uninstalled).
      cleanup = "none";
    };

    taps = [ "supercmdlabs/supercmd" ];

    # CLI tools come from nix. Keep this empty unless something is mac-only
    # and missing from nixpkgs.
    brews = [ ];

    casks = [
      "ghostty"
      "zen"
      "bitwarden"
      "rectangle"
      "supercmdlabs/supercmd/supercmd"
      "spotify"
      "discord"
      "slack"
    ];

    # App Store apps (needs Apple ID sign-in once). nix-darwin installs `mas`.
    masApps = {
      "Caffeinated" = 1362171212;
    };
  };
}
