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
}
