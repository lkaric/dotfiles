{ ... }:
{
  # Determinate Nix owns the daemon, /etc/nix/nix.conf and upgrades
  # (`determinate-nixd upgrade`). nix-darwin must not fight it.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
}
