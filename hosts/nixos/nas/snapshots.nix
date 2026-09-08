{ ... }:

{
  services.sanoid = {
    enable = true;
    interval = "hourly";

    templates.stack-config = {
      autosnap = true;
      autoprune = true;
      hourly = 720;
      daily = 0;
      monthly = 0;
      yearly = 0;
    };

    datasets."Max/docker/stacks" = {
      recursive = false;
      useTemplate = [ "stack-config" ];
    };
  };
}
