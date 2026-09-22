{ user, ... }:
{
  # nix-homebrew installs/adopts Homebrew itself (autoMigrate takes over the
  # existing /opt/homebrew). Packages are declared below via nix-darwin.
  nix-homebrew = {
    enable = true;
    user = user.name;
    autoMigrate = true;
    # No third-party taps declared. If one is ever added it needs explicit
    # trust on Homebrew >= 4.6, both here and in `homebrew.taps` below --
    # otherwise `brew bundle cleanup` aborts on it and stops uninstalling.
    trust.taps = [ ];
  };

  homebrew = {
    enable = true;

    onActivation = {
      # Keep `nrs` fast: no brew update/upgrade on every switch. `nup` does it.
      autoUpdate = false;
      upgrade = false;
      # Anything not declared here is uninstalled on switch (and stays gone).
      cleanup = "zap";
    };

    taps = [ ];

    # CLI tools come from nix. The one exception: `mas` drives the masApps
    # entries below, and it has to be reachable during *system* activation,
    # where the home-manager user profile is not on PATH yet. Homebrew's own
    # bin dir is, so it lives here rather than in home.packages.
    brews = [ "mas" ];

    casks = [
      "ghostty"
      # Editor. Cursor self-updates (cask auto_updates: true); settings live in
      # ~/Library/Application Support/Cursor/User/ and are not tracked yet.
      "cursor"
      # Only browser. Managed policy lives in system-defaults.nix
      # (CustomSystemPreferences) because Chrome honours mandatory policy from
      # the root-owned domain, not the user one.
      "google-chrome"
      # Claude Desktop. MCP config at
      # ~/Library/Application Support/Claude/claude_desktop_config.json.
      "claude"
      # Paper: design tool for interfaces and prototypes (paper.design).
      "paper-design"
      "obsidian"
      "bitwarden"
      "rectangle"
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
