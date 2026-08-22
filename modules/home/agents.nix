{ inputs, pkgs, ... }:
{
  imports = [ inputs.omp.homeManagerModules.default ];

  # Oh My Pi: package from its flake; ~/.omp stays mutable (omp rewrites it).
  programs.omp.enable = true;

  # Herdr: built from its flake (pinned tag in flake.nix).
  home.packages = [ inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
