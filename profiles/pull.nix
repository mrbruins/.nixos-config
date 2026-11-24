{ lib, ... }:

# Always-on machines pull main and deploy it. Import this next to comin's own
# module for the platform. See docs/adr/0001-macbook-does-not-pull.md.
{
  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/mrbruins/.nixos-config.git";
        branches = {
          main.name = "main";
          # Off. By default comin also deploys the branch testing-<host>, which
          # nothing protects.
          testing.name = "";
        };
        poller.period = 300;
      }
    ];
    exporter.listen_address = lib.mkDefault "127.0.0.1";
  };
}
