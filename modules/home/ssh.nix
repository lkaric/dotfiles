{ lib, user, ... }:
let
  agent = "${user.home}/.bitwarden-ssh-agent.sock";
in
{
  # Public keys are tracked in the repo; private keys live in Bitwarden.
  # `IdentityFile ~/.ssh/<name>` works in both worlds: while a private key is
  # still on disk ssh uses it, once only the .pub is left ssh asks the agent.
  home.file.".ssh/personal.pub".source = ../../keys/personal.pub;
  home.file.".ssh/hiveyard.pub".source = ../../keys/hiveyard.pub;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Attribute names are `Host` patterns, values are raw OpenSSH keywords.
    settings = {
      # Personal (github.com/lkaric and everything else on GitHub)
      "github.com" = {
        User = "git";
        IdentityFile = "~/.ssh/personal";
        IdentitiesOnly = "yes";
      };

      # Work (github.com/mladenctrl); git rewrites github.com:mladenctrl/ here.
      "github-hiveyard" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/hiveyard";
        IdentitiesOnly = "yes";
      };

      "*" = lib.hm.dag.entryAfter [ "github.com" "github-hiveyard" ] {
        IdentityAgent = agent;
        AddKeysToAgent = "no";
        ServerAliveInterval = 60;
        HashKnownHosts = "no";
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };
}
