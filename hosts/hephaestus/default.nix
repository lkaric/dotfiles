# Host: hephaestus (personal MacBook Pro, Apple Silicon)
{ user, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking = {
    hostName = "hephaestus";
    computerName = "hephaestus";
    localHostName = "hephaestus";
  };

  system.primaryUser = user.name;
  users.users.${user.name} = {
    name = user.name;
    home = user.home;
  };

  # Host-specific additions go here (extra casks, dock apps, defaults).
  # homebrew.casks = [ ];

  home-manager.users.${user.name} = {
    # Built-in macOS wallpaper "Chroma Blue". On a fresh machine the file only
    # exists after the wallpaper was picked once in System Settings; the
    # activation step skips with a warning until then.
    my.wallpaper = "${user.home}/Library/Application Support/com.apple.mobileAssetDesktop/Chroma Blue.heic";
  };
}
