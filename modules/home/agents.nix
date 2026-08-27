{
  config,
  inputs,
  pkgs,
  user,
  ...
}:
let
  herdr = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [ inputs.omp.homeManagerModules.default ];

  # Oh My Pi: package from its flake.
  programs.omp = {
    enable = true;

    # Written to ~/.omp/agent/config.yml as a writable regular file on every
    # switch (the flake's module does `install -m 600`, not a store symlink,
    # because omp locks and rewrites this file). So: omp owns it at runtime,
    # the rebuild reasserts these values. Use this layer for things you may
    # want to fiddle with live; use config/omp/settings.yml (PI_CONFIG_FILES)
    # for policy that must always win.
    settings = {
      # Skips the onboarding wizard. Without it omp re-runs setup.
      setupVersion = 2;

      modelRoles.default = "anthropic/claude-opus-5";

      # Appearance, as answered in the setup wizard.
      theme = {
        dark = "titanium";
        light = "light";
      };
      symbolPreset = "nerd"; # Nerd Font is installed via fonts.nix
      colorBlindMode = false;
      composer.shape = "box";
      display.shimmer = "classic";
      terminal.showProgress = true;
      omitThinking = false;
      statusLine = {
        preset = "ascii";
        separator = "ascii";
        contextLine = "percentage";
        sessionAccent = true;
        transparent = false;
        compactThinkingLevel = true;
        showHookStatus = true;
      };
      tui = {
        textSizing = false;
        titleState = true;
        hyperlinks = "auto";
        tight = true;
      };

      # Behavior. The advisor model is pinned in config/omp/settings.yml;
      # without modelRoles.advisor this flag is inert.
      advisor = {
        enabled = true;
        syncBacklog = "off";
      };
      bash.enabled = true;
      task.eager = "preferred";
    };
  };

  # Declarative omp policy. omp rewrites config.yml but never an overlay, so
  # tracked settings live in config/omp/settings.yml and win over config.yml.
  home.sessionVariables.PI_CONFIG_FILES = "${user.dotfiles}/config/omp/settings.yml";

  # Herdr: built from its flake (pinned tag in flake.nix).
  home.packages = [ herdr ];

  # Two one-time installs that would otherwise be lost on a fresh machine.
  # Both are idempotent and rerun on every switch on purpose: the Herdr
  # integration is version-matched to the Herdr binary, so a flake bump needs
  # the extension rewritten.
  home.activation.ompIntegrations = {
    before = [ ];
    after = [
      "writeBoundary"
      "ompConfig"
    ];
    data = ''
      # Reports omp lifecycle state (working/blocked/done) to Herdr and enables
      # native `omp --resume`. omp has no screen-detection manifest, so without
      # this every omp pane shows as `unknown`.
      run ${herdr}/bin/herdr integration install omp || \
        warnEcho "herdr: omp integration install failed (non-fatal)"

      # Unpacks the MV3 relay extension to ~/.omp/browser-relay/extension.
      # Loading it into Chrome is still manual (chrome://extensions).
      if [ ! -d "$HOME/.omp/browser-relay/extension" ]; then
        run ${config.programs.omp.package}/bin/omp browser-relay install || \
          warnEcho "omp: browser-relay install failed (non-fatal)"
      fi
    '';
  };
}
