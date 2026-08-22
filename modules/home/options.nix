{ lib, ... }:
{
  # Small custom option namespace for per-host knobs.
  options.my = {
    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Absolute path of the desktop picture applied on activation.";
    };

    colima.autostart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Start Colima at login via a launchd agent.";
    };
  };
}
