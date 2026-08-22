{ pkgs, ... }:
{
  # Installed to /Library/Fonts/Nix Fonts. Add a font = add a line.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono # terminal, nvim, TUIs (icons)
    inter # UI / sans
  ];
}
