{ config, user, ... }:
let
  # Symlink into the checked-out repo, not the nix store: edits are live.
  link = path: config.lib.file.mkOutOfStoreSymlink "${user.dotfiles}/config/${path}";
in
{
  xdg.configFile = {
    # whole directories
    "nvim".source = link "nvim";
    "ghostty".source = link "ghostty";
    # single files (so the apps can keep their own state next to them)
    "starship.toml".source = link "starship.toml";
    "sheldon/plugins.toml".source = link "sheldon/plugins.toml";
    "tmux/tmux.conf".source = link "tmux/tmux.conf";
    "mise/config.toml".source = link "mise/config.toml";
    "atuin/config.toml".source = link "atuin/config.toml";
    "herdr/config.toml".source = link "herdr/config.toml";
  };
}
