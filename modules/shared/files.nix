{ pkgs, config, ... }:

let
  user = "michielbruins";
  sshHome = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${user}/.ssh" else "/home/${user}/.ssh";
  externalSshConfig = "${sshHome}/config_external";
  enecoIdentityFile = "~/.ssh/id_rsa_eneco";
in {

  ".ssh/config" = {
    text = ''
    ${if pkgs.stdenv.hostPlatform.isDarwin then ''
      Host *
        UserKnownHostsFile ~/.ssh/known_hosts
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        
      '' else ""}

      # Host eneco-bv.ghe.com
      #   HostName eneco-bv.ghe.com
      #   User git
      #   IdentityFile ${enecoIdentityFile}
      #   IdentitiesOnly yes

      # Host ssh.dev.azure.com
      #   HostName ssh.dev.azure.com
      #   User git
      #   IdentityFile ${enecoIdentityFile}
      #   IdentitiesOnly yes
    '';
  };

  ".config/git/config-personal" = {
    text = ''
      [user]
          name = mrbruins
          email = michiel@m11s.nl

      # [url "git@github.com:"]
      #     insteadOf = https://github.com/
    '';
  };

  ".config/git/config-work" = {
    text = ''
      [user]
          name = Michiel-Bruins
          email = michiel.bruins@eneco.com
    '';
  };

    ".npmrc" = {
      text = ''
        registry=https://registry.npmjs.org/
        prefix=${if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${user}/.npm-packages" else "/home/${user}/.npm-packages"}
      '';
    };
}
