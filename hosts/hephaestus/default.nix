# Host: hephaestus (personal MacBook Pro, Apple Silicon)
{ user, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking = {
    hostName = "hephaestus";
    computerName = "hephaestus";
    # Bonjour name (<name>.local). hephaestus.local is taken by another device
    # on the home LAN, so this one is different on purpose.
    localHostName = "lkaric";
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
