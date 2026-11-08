{ ... }:

let
  user = "michielbruins";
in

# Portable nix-darwin baseline shared by every Mac host (MacBook, Mac Studio).
# Keep laptop-, GUI- and secrets-specific settings in the host profiles.
{
  imports = [ ../shared ];

  # Determinate manages the Nix installation; disable nix-darwin's management.
  nix.enable = false;

  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 5;
  };
}
