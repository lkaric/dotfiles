{
  config,
  pkgs,
  lib,
  user,
  ...
}:
{
  home.packages = with pkgs; [
    colima
    docker-client
    docker-compose
    docker-buildx
  ];

  # `docker compose` / `docker buildx` subcommands. force: Docker Desktop left
  # its own symlinks here, which HM otherwise refuses to replace.
  home.file.".docker/cli-plugins/docker-compose" = {
    source = "${pkgs.docker-compose}/bin/docker-compose";
    force = true;
  };
  home.file.".docker/cli-plugins/docker-buildx" = {
    source = "${pkgs.docker-buildx}/bin/docker-buildx";
    force = true;
  };

  # VM template for new profiles (config/colima/default.yaml, mutable).
  home.file.".colima/_templates/default.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "${user.dotfiles}/config/colima/default.yaml";

  launchd.agents.colima = lib.mkIf config.my.colima.autostart {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.colima}/bin/colima"
        "start"
        "--foreground"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      EnvironmentVariables.PATH = "${pkgs.colima}/bin:${pkgs.docker-client}/bin:/usr/bin:/bin";
      StandardOutPath = "${user.home}/Library/Logs/colima.log";
      StandardErrorPath = "${user.home}/Library/Logs/colima.err.log";
    };
  };
}
