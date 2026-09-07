{ pkgs, user, ... }:
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

  # bootstrap.sh runs `lefthook install`, but a clone that never ran it has no
  # .git/hooks/pre-commit and the formatters silently do not run. Reassert it
  # on every switch; it just rewrites the hook shims.
  home.activation.lefthookInstall = {
    before = [ ];
    after = [ "writeBoundary" ];
    data = ''
      # Two traps: `lefthook install` has no --dir flag, so it must run from
      # the repo root; and it shells out to `git`, which is not on the
      # activation PATH. Without git it exits non-zero with
      # `exec: "git": executable file not found in $PATH` and writes no hook.
      if [ -d "${user.dotfiles}/.git" ]; then
        run ${pkgs.bash}/bin/sh -c \
          'cd "${user.dotfiles}" && PATH="${pkgs.git}/bin:$PATH" exec ${pkgs.lefthook}/bin/lefthook install --force' || \
          warnEcho "lefthook: install failed (non-fatal)"
      fi
    '';
  };
}
