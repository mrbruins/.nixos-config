{ pkgs, ... }:

let
  # Mails stdin. Uses nothing that runs on the NAS itself. The account is in
  # /etc/nas/mail, placed by hand from 1Password (docs/nas-cutover.md), so it
  # is neither in the repository nor in the Nix store. Every alert also goes to
  # the journal.
  nas-alert = pkgs.writeShellApplication {
    name = "nas-alert";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.hostname
      pkgs.util-linux
    ];
    text = ''
      # smartd and ZED pass mail(1) arguments; only the text matters.
      message="$(cat)"
      logger --tag nas-alert --priority daemon.warning -- "$message" || true

      if [[ ! -r /etc/nas/mail ]]; then
        echo "nas-alert: /etc/nas/mail is missing, alert not mailed" >&2
        exit 1
      fi
      server=smtp://smtp.mail.me.com:587 # STARTTLS, required below
      user="" password="" from="" to=""
      while IFS='=' read -r key value; do
        case "$key" in
          server) server="$value" ;;
          user) user="$value" ;;
          password) password="$value" ;;
          from) from="$value" ;;
          to) to="$value" ;;
        esac
      done < /etc/nas/mail

      subject="$(head -n 1 <<< "$message" | tr -d '\r' | cut -c 1-120)"
      mail="$(mktemp)"
      trap 'rm -f "$mail"' EXIT
      {
        printf 'From: %s\r\nTo: %s\r\n' "$from" "$to"
        printf 'Subject: [%s] %s\r\n' "$(hostname)" "''${subject:-alert}"
        printf 'Date: %s\r\n' "$(date --rfc-email)"
        printf 'Message-ID: <%s@%s>\r\n' "$(cat /proc/sys/kernel/random/uuid)" "''${from#*@}"
        printf 'Content-Type: text/plain; charset=utf-8\r\n\r\n'
        while IFS= read -r line; do printf '%s\r\n' "$line"; done <<< "$message"
      } > "$mail"

      # The password goes through a file descriptor, not the process list.
      curl --silent --show-error --max-time 60 --retry 3 --retry-all-errors \
        --ssl-reqd --url "$server" --config <(printf 'user = "%s:%s"\n' "$user" "$password") \
        --mail-from "$from" --mail-rcpt "$to" --upload-file "$mail"
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
        echo "$1 failed" | ${nas-alert}/bin/nas-alert
      '';
    };
    sanoid.onFailure = [ "nas-alert@%n.service" ];
    docker.onFailure = [ "nas-alert@%n.service" ];
    zfs-mount.onFailure = [ "nas-alert@%n.service" ];
    # A monthly sign of life, so silence means something.
    nas-alert-monthly = {
      description = "Mail a monthly status report";
      startAt = "*-*-01 09:00";
      serviceConfig.Type = "oneshot";
      path = [
        nas-alert
        pkgs.zfs
      ];
      script = ''
        { echo "Monthly status"; zpool status; zpool list; } | nas-alert
      '';
    };
  };
}
