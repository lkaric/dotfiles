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
    # Zed rewrites settings.json at runtime (theme picker, Settings Editor), so
    # it must resolve to a writable path -- mkOutOfStoreSymlink, never the store.
    "zed/settings.json".source = link "zed/settings.json";
    # gh rewrites config.yml (`gh config set`, `gh alias set`), so same rule.
    # Auth stays in the untracked sibling hosts.yml.
    "gh/config.yml".source = link "gh/config.yml";
  };

  # omp reads these but never writes them, so they are safe to symlink into the
  # otherwise-mutable ~/.omp. Settings live in config/omp/settings.yml, loaded
  # via PI_CONFIG_FILES (modules/home/agents.nix) rather than symlinked over
  # config.yml, which omp rewrites.
  home.file = {
    ".omp/agent/agents".source = link "omp/agents";
    ".omp/agent/skills".source = link "omp/skills";
    ".omp/agent/WATCHDOG.md".source = link "omp/WATCHDOG.md";
  };
}
