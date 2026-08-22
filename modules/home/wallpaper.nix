{ config, lib, ... }:
let
  wp = config.my.wallpaper;
in
{
  # Runs as the user on every switch. First run prompts once to allow the
  # terminal to control System Events (TCC); accept it.
  home.activation.wallpaper = lib.mkIf (wp != null) (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f ${lib.escapeShellArg wp} ]; then
        run /usr/bin/osascript -e ${lib.escapeShellArg ''tell application "System Events" to tell every desktop to set picture to "${wp}"''} \
          || echo "wallpaper: osascript failed (allow System Events automation for your terminal)"
      else
        echo "wallpaper: ${wp} not found, skipping (pick it once in System Settings)"
      fi
    ''
  );
}
