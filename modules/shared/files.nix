{ pkgs, config, ... }:

let
  user = "michielbruins";
  sshHome = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${user}/.ssh" else "/home/${user}/.ssh";
  externalSshConfig = "${sshHome}/config_external";
  enecoIdentityFile = "~/.ssh/id_rsa_eneco";
in {

  # ".ssh/id_github.pub" = {
  #   text = githubPublicKey;
  # };

  # Initializes Emacs with org-mode so we can tangle the main config
  # ".emacs.d/init.el" = {
  #   text = builtins.readFile ../shared/config/emacs/init.el;
  # };

  # IMPORTANT: The Emacs configuration expects a config.org file at ~/.config/emacs/config.org
  # You can either:
  # 1. Copy the provided config.org to ~/.config/emacs/config.org
  # 2. Set EMACS_CONFIG_ORG environment variable to point to your config.org location
  # 3. Uncomment below to have Nix manage the file:
  #
  # ".config/emacs/config.org" = {
  #   text = builtins.readFile ../shared/config/emacs/config.org;
  # };

  ".ssh/config" = {
    text = ''
    ${if pkgs.stdenv.hostPlatform.isDarwin then ''
      Host github.com
        HostName github.com
        User git     
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        IdentitiesOnly yes
      '' else ""}

      Host eneco-bv.ghe.com
        HostName eneco-bv.ghe.com
        User git
        IdentityFile ${enecoIdentityFile}
        IdentitiesOnly yes

      Host ssh.dev.azure.com
        HostName ssh.dev.azure.com
        User git
        IdentityFile ${enecoIdentityFile}
        IdentitiesOnly yes

      ${if pkgs.stdenv.hostPlatform.isDarwin then ''
      Host m11s.nl
        HostName m11s.nl
        User git     
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        IdentitiesOnly yes
      '' else ""}

      Include ${externalSshConfig}

      Host *
          UserKnownHostsFile ~/.ssh/known_hosts
          ForwardAgent no
          AddKeysToAgent no
    '';
  };

  ".config/git/config-personal" = {
    text = ''
      [user]
          name = mrbruins
          email = michiel@m11s.nl

      [url "git@github.com:"]
          insteadOf = https://github.com/
    '';
  };

  ".config/git/config-work" = {
    text = ''
      [user]
          name = Michiel-Bruins
          email = michiel.bruins@eneco.com

      [url "git@eneco-bv.ghe.com:"]
          insteadOf = https://eneco-bv.ghe.com/
    '';
  };
}
