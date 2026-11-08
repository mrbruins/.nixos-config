{ pkgs, ... }:

let
  user = "michielbruins";
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p"
  ];
in

# NixOS agent host: an x86_64 VM on TrueNAS SCALE that will run devvm/Lima
# cells with nested KVM, Tailscale and remote t3code (implementation plan,
# phase 7). This is a minimal, bootable baseline. No secrets yet.
{
  imports = [ ./agent-host/hardware.nix ];

  networking.hostName = "agent-host";

  # UEFI boot (TrueNAS VMs boot through OVMF).
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 20;
    };
    efi.canTouchEfiVariables = true;
  };

  # Nested virtualisation for devvm/Lima cells. The TrueNAS host CPU is an
  # Intel i9-13900HX; the VM must be given host-passthrough CPU mode.
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  networking.firewall.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Joining the tailnet is a manual step (`tailscale up`) until auth keys are
  # handled through secrets.
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  users.users.${user} = {
    isNormalUser = true;
    # wheel: sudo (requires a password; set one on first console login).
    # kvm: access to /dev/kvm for nested cells.
    extraGroups = [
      "wheel"
      "kvm"
    ];
    openssh.authorizedKeys.keys = keys;
  };

  # No password login for root.
  users.users.root.hashedPassword = "!";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
  ];

  # Set once at first install; do not change afterwards.
  system.stateVersion = "26.05";
}
