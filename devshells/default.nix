{ pkgs }:

# Language tools for projects that do not bring their own devshell. `rig env
# <name>` in a project uses one through direnv. Nothing here is installed.
{
  go = pkgs.mkShell {
    packages = with pkgs; [
      delve
      go
      golangci-lint
      gopls
    ];
    # Use this Go, whatever a go.mod asks to download.
    GOTOOLCHAIN = "local";
  };

  node22 = pkgs.mkShell { packages = [ pkgs.nodejs_22 ]; };
}
