{ pkgs, ... }:

let
  # Posts stdin to the URL in /etc/nas/alert-url (ntfy, or any webhook that
  # takes plain text). The file is placed by hand. Without it, alerts only
  # reach the journal.
  nas-alert = pkgs.writeShellApplication {
    name = "nas-alert";
    runtimeInputs = [
      pkgs.curl
      pkgs.util-linux
    ];
    text = ''
      message="$(cat)"
      logger --tag nas-alert --priority daemon.warning -- "$message"
      if [[ -r /etc/nas/alert-url ]]; then
        curl --fail --silent --show-error --max-time 20 \
          --data-binary "$message" "$(< /etc/nas/alert-url)"
      fi
    '';
  };
in
{
  environment.systemPackages = [ nas-alert ];

  services = {
    # Pool events: degraded pools, errors, finished scrubs and resilvers.
    zfs.zed = {
      enableMail = false;
      settings = {
        ZED_EMAIL_ADDR = [ "root" ];
        ZED_EMAIL_PROG = "${nas-alert}/bin/nas-alert";
        ZED_EMAIL_OPTS = "";
        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;
      };
    };

    smartd = {
      enable = true;
      # Short test daily at 02:00, long test on the 1st of the month at 03:00.
      defaults.monitored = "-a -s (S/../.././02|L/../01/./03)";
      notifications.mail = {
        enable = true;
        mailer = "${nas-alert}/bin/nas-alert";
      };
    };
  };

  # A failed unit that protects data is an alert too.
  systemd.services = {
    "nas-alert@" = {
      description = "Alert about %i";
      serviceConfig.Type = "oneshot";
      scriptArgs = "%i";
      script = ''
        echo "$1 failed on $(cat /proc/sys/kernel/hostname)" | ${nas-alert}/bin/nas-alert
      '';
    };
    sanoid.onFailure = [ "nas-alert@%n.service" ];
    docker.onFailure = [ "nas-alert@%n.service" ];
    zfs-mount.onFailure = [ "nas-alert@%n.service" ];
  };
}
