{ inputs, pkgs, ... }:
let
  herdr = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  # Herdr: built from its flake (pinned tag in flake.nix).
  home.packages = [ herdr ];
}
