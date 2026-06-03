{ pkgs, config, ... }:

let
  user = "michielbruins";
  sshHome = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${user}/.ssh" else "/home/${user}/.ssh";
  externalSshConfig = "${sshHome}/config_external";
  truenasIdentityFile = "~/.config/ssh/public-keys/truenas.pub";
  enecoIdentityFile = "~/.ssh/id_rsa_eneco";
in {

  ".config/ssh/public-keys/truenas.pub" = {
    text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBRj2sHfADZUIrwDwsLRsDCWaS8yuggc/vzQ0nh7Ht2I SSH - TrueNAS
    '';
  };

  ".ssh/config" = {
    text = ''
    ${if pkgs.stdenv.hostPlatform.isDarwin then ''
      Include ${externalSshConfig}
      Include ~/.ssh/1Password/config

      Host *
        UserKnownHostsFile ~/.ssh/known_hosts
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        AddKeysToAgent no
        ForwardAgent no
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
          email = 1969831+mrbruins@users.noreply.github.com
          signingkey = ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyC8wND8XWbh+iRDlmc8h/Eso47O0J27xd4I530VUI/ShONn/nFLH6u14jlIMHpSR5CHw0d0gPS5Bfj7Z8uCVutE5ywCC3PU/JcD5KqIyrftskJYYkziDAYHt4qlzRul6la2aFEYHnwtbznATaaTSy2kljeMfP9/3LubCXnlcn4EKChm9OgpHF3L74zQfOCVA5OMXmblopTBzneinhgyko0Qunt3woeTFDJ+BuFVhRLi0xMNShVxJO5BwoSxslEb9gmHzJzfULnopkichF2CQdabhau6yxo/6Q2fKZScbfGBx+bOHU5qwLkaDub6Qu085YV/f1KfUYcJOtvPoP1knChbQeGmwFJCNjn/sW0OmusLykIppo8QJA5QfZlXPzrvmzRN00txnHJFe80vN+IfEOC0ey95HxBFw3qoL/KubevZOGErw65vbhxQzRRyvXth/cTUBq3JRaxdNtPvDQSyXeNso2b22LfoZ1ML75ZS5/UEf9TFpqMIwyYEEI+48ZMHllkT+ACCH3HgFEJ5e66qHOpAchanLdZf0FFJYru1QCMtJlbBhwhKiJhTldsPfiA2pGReHsvdXNqC+4ISwTwb9Hb41448dAuGM7mDpgLlODvvR8oxkkxzaDyAQvmvlNbxhKMaa3Gl6M2JYqLFXr6zLtcQhHTuDfa6jK5iu7lIFq0w==

      [gpg]
        format = ssh

      [gpg "ssh"]
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"

      [commit]
        gpgsign = true
    '';
  };

  ".config/git/config-managed" = {
    text = ''
      [core]
        editor = vim
        autocrlf = input
        excludesfile = ~/.config/git/ignore

      [init]
        defaultBranch = main

      [credential]
        azreposCredentialType = oauth

      [credential "azrepos:org/enecomanagedcloud"]
        username = Michiel.Bruins@eneco.com

      [commit]
        gpgsign = true

      [pull]
        rebase = true

      [rebase]
        autoStash = true

      [gpg]
        format = openpgp

      [gpg "openpgp"]
        program = ${pkgs.gnupg}/bin/gpg

      [filter "lfs"]
        clean = ${pkgs.git-lfs}/bin/git-lfs clean -- %f
        process = ${pkgs.git-lfs}/bin/git-lfs filter-process
        required = true
        smudge = ${pkgs.git-lfs}/bin/git-lfs smudge -- %f
    '';
  };

  ".config/git/config-platform" = {
    text = if pkgs.stdenv.hostPlatform.isDarwin then ''
      [credential "https://dev.azure.com"]
        helper = ${pkgs.git-credential-manager}/bin/git-credential-manager
        azreposCredentialType = oauth
        credentialStore = keychain
        useHttpPath = true
    '' else "";
  };

  ".config/git/config-work" = {
    text = ''
      [user]
          name = Michiel-Bruins
          email = michiel.bruins@eneco.com
          signingkey = ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6VpyQjfX83LGgNGVZkz2uECoOsQnIcQUnB3MuVCIj+I0XJymNHlEuEe/P3IG98Oh12dkhu2b38NwLcz11K4s5KGWRJOHVe4OZ6kF8DHNnAYuvHarRGyC3PuompachBcBxTY85UK9aUd1AbLsOwgnw0AyMjZHl0HAFu2Tif1YMJ+6gO5zCM9tOecflT97Xw/JiX408YPqJCaNPFPksjCAT6H/Yfux/SnW4sPQXw0yV12o3+0OD6m8+uWBryWna+NNcGh4prL6NDQCHLclc83xpVbLx8Cd0+jYShl0QYCGhvh8XfLA1UMg3+2m7ozcnDTqmcuxM5ESB1gpHRNLyLSBD4hXuw9niszMopIgK7i9N2iV+yq7qrTn64gvhpfWD673P+D78IiYNuYbBWlYEugrKXwWD+Wn1r34fnRs+Td9XBYIgRXBy8YpHgctpw1gUpMUmRPUJnFiNlYgVz+1bAtT59V4Iw+WlbgMo5wIfk1bqNB/muAl28YEo71/swead4IM=

      [gpg]
        format = ssh

      [gpg "ssh"]
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"

      [commit]
        gpgsign = true
    '';
  };

  ".config/git/ignore" = {
    text = ''
      *.swp
    '';
  };

    ".npmrc" = {
      text = ''
        registry=https://registry.npmjs.org/
        prefix=${if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${user}/.npm-packages" else "/home/${user}/.npm-packages"}
      '';
    };
}
