{ lib, pkgs, ... }:

let
  user = "michielbruins";
in

# Mac Studio (M1 Max, 64 GB): serves local inference, behind LiteLLM later.
#
# Deliberately minimal. Not included here, compared with the MacBook:
# - Homebrew / nix-homebrew, casks and Mac App Store apps.
# - Dock, trackpad, keyboard and Touch ID settings.
# - The workstation profile.
#
# Going headless is deferred, so Screen Sharing and login items stay under human
# control. So do FileVault, SIP and Gatekeeper, which must stay on.
{
  imports = [
    ../../modules/darwin/base.nix
  ];

  networking.hostName = "Mac-Studio";

  # A sleeping Mac serves nothing: no SSH or Ollama. The displays may
  # still sleep. After a power failure it starts, but waits at FileVault.
  power = {
    restartAfterPowerFailure = true;
    sleep.computer = "never";
  };

  environment.systemPackages = [ pkgs.ollama ];

  programs._1password.enable = true;

  # The app is there for the QR sign-in and the SSH agent. It updates itself, so
  # Nix only puts it there the first time. programs._1password-gui would replace
  # it on every activation, which macOS refuses over SSH (App Management).
  system.activationScripts.applications.text = lib.mkAfter ''
    if [[ ! -e /Applications/1Password.app ]]; then
      echo "installing 1Password..." >&2
      /usr/bin/ditto ${pkgs._1password-gui}/Applications/1Password.app /Applications/1Password.app
      /usr/sbin/chown -R ${user}:staff /Applications/1Password.app
      /bin/chmod -R u+w /Applications/1Password.app
    fi
  '';

  services = {
    # Remote Login with keys only. After a cold boot macOS still accepts the
    # account password over SSH, once, to unlock FileVault: this configuration
    # is on the locked volume (apple_ssh_and_filevault(7)).
    openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication no
        KbdInteractiveAuthentication no
        PermitRootLogin no
        AllowUsers ${user}
      '';
    };

    # A system daemon, so the tailnet works before anyone logs in.
    tailscale.enable = true;
  };

  # Loopback only: LiteLLM access needs a firewall rule that admits only the
  # NAS, which is not designed yet. No models are declared.
  launchd.daemons.ollama = {
    command = "${pkgs.ollama}/bin/ollama serve";
    serviceConfig = {
      UserName = user;
      KeepAlive = true;
      RunAtLoad = true;
      EnvironmentVariables = {
        HOME = "/Users/${user}";
        OLLAMA_HOST = "127.0.0.1:11434";
      };
      StandardOutPath = "/Users/${user}/Library/Logs/ollama.log";
      StandardErrorPath = "/Users/${user}/Library/Logs/ollama.log";
    };
  };

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
    shell = pkgs.zsh;
    # Private key in 1Password.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOp28HbDC8fXvje0Vna4Qp11HGRg87vxJDnrfDqRKGP58rw0fbHgdhcFRevEQOL/RkU/iZfmc4h2kfz0zsw4UeXOs392t6NH5hJzlmCc4x5zu8Qri3CWQQRxwT3ShwaVHjrFTWQR2hw2jpN6HZOk/ZG8E5gBsQXVnd5EoL9l87FGm39eH8Lbns3e/ZA2B8uvYRPaDbCJQWAZKp6xLXUHmu058ABTHq+M2rKzA71DA2YEyIviMBUhHw5TWFyarhpFaJhcMdmCHBBMYNdS4hpf9OL/LWtbQVQXa0LlyZ91NpDA6cTpQRgJvwa1JRH8/4Lor/ecM3+6FzsOwGXTnQ+bG2Ta+8F7yj551NSgyuHzodUNKtq0Gl/ALpd3cit6FCvRS6E65MlbsFTw7OPWNCWotUnxGP7zM/JsiiF58WrHPk6zJvHbz3vypZ62+eUktTL8IT72VpiZSm8SAClE9lMgCthNdnNGStX6Sed7fiusGBf0UaqV+Nntg/z5+hzhAMg1k="
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.${user} = {
      imports = [ ../../profiles/cli ];

      home.stateVersion = "26.05";
      home.enableNixpkgsReleaseCheck = false;
      manual.manpages.enable = false;
    };
  };
}
