{ pkgs }:

# nas-alert delivers a mail over TLS with a login, and fails loudly without one.
let
  tls = pkgs.runCommand "tls" { nativeBuildInputs = [ pkgs.openssl ]; } ''
    mkdir $out
    openssl req -x509 -newkey rsa:2048 -nodes -days 36500 -subj /CN=mail \
      -addext subjectAltName=DNS:mail -keyout $out/key.pem -out $out/cert.pem
  '';
  server =
    pkgs.writers.writePython3 "smtp-server"
      {
        libraries = [ pkgs.python3Packages.aiosmtpd ];
        doCheck = false;
      }
      ''
        import ssl, time
        from aiosmtpd.controller import Controller
        from aiosmtpd.smtp import AuthResult

        class Handler:
            async def handle_DATA(self, server, session, envelope):
                with open("/tmp/mail", "wb") as f:
                    f.write(envelope.content)
                return "250 OK"

        def auth(server, session, envelope, mechanism, data):
            ok = data.login == b"nas@example.org" and data.password == b"abcd-efgh"
            return AuthResult(success=ok)

        context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
        context.load_cert_chain("${tls}/cert.pem", "${tls}/key.pem")
        Controller(Handler(), hostname="0.0.0.0", port=465, ssl_context=context,
                   authenticator=auth, auth_required=True, auth_require_tls=False).start()
        while True:
            time.sleep(60)
      '';
in
pkgs.testers.runNixOSTest {
  name = "nas-alerts";

  nodes = {
    mail = {
      networking.firewall.allowedTCPPorts = [ 465 ];
      systemd.services.smtp = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = server;
      };
    };
    nas = {
      imports = [ ../hosts/nixos/nas/alerts.nix ];
      networking.hostId = "11346ac0";
      boot.supportedFilesystems.zfs = true;
      security.pki.certificateFiles = [ "${tls}/cert.pem" ];
      # No disks with SMART here.
      services.smartd.enable = pkgs.lib.mkForce false;
      services.sanoid.enable = true;
      virtualisation.docker.enable = true;
    };
  };

  testScript = ''
    start_all()
    mail.wait_for_open_port(465)
    nas.wait_for_unit("multi-user.target")

    with subtest("without an account it fails instead of pretending"):
        nas.fail("echo test | nas-alert")

    nas.succeed("mkdir -p /etc/nas && umask 077 && printf 'server=smtps://mail:465\nuser=nas@example.org\npassword=abcd-efgh\nfrom=nas@example.org\nto=me@example.org\n' > /etc/nas/mail")

    with subtest("a mail arrives, and the password is not in it"):
        nas.succeed("printf 'Pool is degraded\nsecond line\n' | nas-alert -s ignored root")
        mail.succeed("grep -F 'Subject: [nas] Pool is degraded' /tmp/mail")
        mail.succeed("grep -F 'second line' /tmp/mail")
        mail.fail("grep -F 'abcd-efgh' /tmp/mail")

    with subtest("a wrong password is an error"):
        nas.succeed("sed -i s/abcd/wrong/ /etc/nas/mail")
        nas.fail("echo test | nas-alert")
  '';
}
