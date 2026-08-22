{ ... }:
{
  # Touch ID for sudo (also works inside tmux via pam_reattach when needed).
  security.pam.services.sudo_local.touchIdAuth = true;
}
