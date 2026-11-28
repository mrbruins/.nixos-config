{ pkgs, ... }:

# Home Manager profile for the machine you sit at.
{
  imports = [
    ../cli
    ./ssh.nix
  ];

  home.packages = import ./packages.nix { inherit pkgs; };

  # Its installer wrote this path into the agents' MCP and hook settings.
  home.file.".local/bin/codebase-memory-mcp".source =
    "${pkgs.codebase-memory-mcp}/bin/codebase-memory-mcp";

  # Exempt tools that `rig update` installs from npm at their latest release
  # (docs/adr/0003-seven-day-cooldown.md). cf is Cloudflare's CLI; nixpkgs'
  # cloudflare-cli is a different tool.
  home.file.".config/rig/npm-tools".text = ''
    cf
  '';
}
