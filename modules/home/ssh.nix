{ user, ... }:
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

    matchBlocks = {
      "*" = {
        identityAgent = agent;
        addKeysToAgent = "no";
        serverAliveInterval = 60;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
      };

      # Personal (github.com/lkaric and everything else on GitHub)
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/personal";
        identitiesOnly = true;
      };

      # Work (github.com/mladenctrl); git rewrites github.com:mladenctrl/ here.
      "github-hiveyard" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/hiveyard";
        identitiesOnly = true;
      };
    };
  };
}
