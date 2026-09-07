{ ... }:
{
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 45;
      mru-spaces = false;
      minimize-to-application = true;
      # Fixed dock, in this order. Apps not in the list are removed from the
      # dock on every switch (running apps still show up while open).
      persistent-apps = [
        "/Applications/Ghostty.app"
        "/Applications/Google Chrome.app"
        "/Applications/Slack.app"
        "/Applications/Discord.app"
        "/Applications/Spotify.app"
        "/Applications/Bitwarden.app"
      ];
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Nlsv"; # list view
      FXEnableExtensionChangeWarning = false;
      FXDefaultSearchScope = "SCcf"; # search current folder
      _FXShowPosixPathInTitle = true;
      NewWindowTarget = "Home";
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false; # key repeat instead of accent popup
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };

    trackpad = {
      Clicking = true; # tap to click
      TrackpadRightClick = true;
    };

    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    loginwindow.GuestEnabled = false;

    # App preferences that are plain `defaults` domains.
    CustomUserPreferences = {
      # Rectangle, seeded from the pre-nix prefs on hephaestus.
      "com.knollsoft.Rectangle" = {
        SUEnableAutomaticChecks = true;
        allowAnyShortcut = true;
        alternateDefaultShortcuts = true;
        hideMenubarIcon = true;
        launchOnLogin = true;
        subsequentExecutionMode = 1;
        reflowTodo = {
          keyCode = 45;
          modifierFlags = 786432;
        };
        toggleTodo = {
          keyCode = 11;
          modifierFlags = 786432;
        };
      };

      "design.yugen.Caffeinated" = {
        showWelcomeWindowAtLaunch = false;
      };

    };

    # Root-owned domain: Chrome treats values it cannot write as mandatory
    # policy. ExtensionInstallForcelist in particular only works as mandatory,
    # which is why this cannot live in CustomUserPreferences. Bitwarden
    # documents this .plist route for extension deployment. Verify after a
    # switch at chrome://policy.
    CustomSystemPreferences."com.google.Chrome" = {
      # Bitwarden owns passwords: built-in manager off, extension forced.
      # nngceckbapebfimnlniiiahkandclblb is the Bitwarden extension id.
      ExtensionInstallForcelist = [
        "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx"
      ];
      PasswordManagerEnabled = false;
      MetricsReportingEnabled = false;
      # Chrome is the only browser, so let it own the default-browser setting.
      DefaultBrowserSettingEnabled = true;
      # No promo or first-run tabs.
      PromotionalTabsEnabled = false;
    };
  };

  # Apply `defaults` changes without logout where macOS allows it.
  system.activationScripts.postActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
  '';
}
