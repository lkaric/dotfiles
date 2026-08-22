{ user, ... }:
{
  imports = [
    ./options.nix
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./ssh.nix
    ./docker.nix
    ./dotfiles.nix
    ./agents.nix
    ./wallpaper.nix
  ];

  home = {
    username = user.name;
    homeDirectory = user.home;
    # home-manager state format; bump only after reading the HM release notes.
    stateVersion = "25.11";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      # Bitwarden desktop SSH agent (direct-download / cask build socket path).
      SSH_AUTH_SOCK = "${user.home}/.bitwarden-ssh-agent.sock";
    };

    sessionPath = [ "${user.home}/.local/bin" ];
  };

  programs.home-manager.enable = true;
  xdg.enable = true;
}
