{ pkgs, ... }:
{
  # Shell-integrated tools (starship, sheldon, atuin, eza, mise, git, gh) are
  # enabled in shell.nix / git.nix; this is everything else.
  home.packages = with pkgs; [
    # editor
    neovim

    # terminal
    tmux

    # unix toolbox
    ffmpeg
    jq
    yq-go
    ripgrep
    fd
    curl
    wget

    # repo tooling (lefthook + formatters)
    lefthook
    nixfmt
    stylua
    taplo
    prettier
  ];
}
