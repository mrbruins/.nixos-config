_:

# Media is left out while Lewis is nearly full, except the home movies.
{
  services.sanoid = {
    enable = true;
    templates.keep = {
      autosnap = true;
      autoprune = true;
      hourly = 0;
      daily = 14;
      weekly = 8;
      monthly = 0;
      yearly = 0;
    };
    datasets = {
      "Lewis/Media/home-movies".useTemplate = [ "keep" ];
      "Lewis/backups".useTemplate = [ "keep" ];
      "Lewis/photos".useTemplate = [ "keep" ];
      "Lewis/videos".useTemplate = [ "keep" ];
      "Max/VMs/haos-vm".useTemplate = [ "keep" ];
      "Max/docker/data".useTemplate = [ "keep" ];
      "Max/docker/stacks".useTemplate = [ "keep" ];
    };
  };
}
