{ config, ... }:

# comin builds main as it changes, but the NAS switches only in this window.
# To deploy sooner: sudo comin confirmation accept
{
  services.comin.deployConfirmer.mode = "manual";

  systemd = {
    services.comin-window = {
      description = "Deploy the built configuration";
      requires = [ "comin.service" ];
      after = [ "comin.service" ];
      serviceConfig.Type = "oneshot";
      path = [ config.services.comin.package ];
      script = "comin confirmation accept";
      onFailure = [ "nas-alert@%n.service" ];
    };
    timers.comin-window = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "Sun 05:00";
    };
  };
}
