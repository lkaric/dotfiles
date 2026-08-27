{
  inputs,
  pkgs,
  user,
  ...
}:
{
  imports = [ inputs.omp.homeManagerModules.default ];

  # Oh My Pi: package from its flake; ~/.omp stays mutable (omp rewrites it).
  programs.omp.enable = true;

  # Declarative omp policy. omp rewrites config.yml but never an overlay, so
  # tracked settings live in config/omp/settings.yml and win over config.yml.
  home.sessionVariables.PI_CONFIG_FILES = "${user.dotfiles}/config/omp/settings.yml";

  # Herdr: built from its flake (pinned tag in flake.nix).
  home.packages = [ inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
