{ config, pkgs, lib, ... }:

let
  user = "michielbruins";
  xdg_configHome  = "/home/${user}/.config";
  gitConfigBootstrap = ''
    # This file stays writable so Git helpers can update global settings.
    [include]
      path = ~/.config/git/config-managed
    [include]
      path = ~/.config/git/config-platform
    [includeIf "gitdir:~/dev/personal/"]
      path = ~/.config/git/config-personal
    [includeIf "gitdir:~/dev/Eneco/"]
      path = ~/.config/git/config-work
  '';
  shared-programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
  shared-files = import ../shared/files.nix { inherit config pkgs; };

in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    file = shared-files // import ./files.nix { inherit user; };
    stateVersion = "26.05";
  };
  home.activation.gitWritableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    git_config_dir="${config.home.homeDirectory}/.config/git"
    git_config_file="$git_config_dir/config"

    mkdir -p "$git_config_dir"
    rm -f "$git_config_file"
    cat > "$git_config_file" <<'EOF'
${gitConfigBootstrap}
EOF
    chmod 600 "$git_config_file"
  '';

  # Use a dark theme
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Screen lock
  services = {
    screen-locker = {
      enable = true;
      inactiveInterval = 10;
      lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 15";
    };

    # Auto mount devices
    udiskie.enable = true;

    polybar = {
      enable = true;
      config = polybar-config;
      extraConfig = polybar-bars + polybar-colors + polybar-modules + polybar-user_modules;
      package = pkgs.polybarFull;
      script = "polybar main &";
    };

    dunst = {
      enable = true;
      package = pkgs.dunst;
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          border = 0;
          height = 400;
          width = 320;
          offset = "33x65";
          indicate_hidden = "yes";
          shrink = "no";
          separator_height = 0;
          padding = 32;
          horizontal_padding = 32;
          frame_width = 0;
          sort = "no";
          idle_threshold = 120;
          font = "Noto Sans";
          line_height = 4;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          transparency = 10;
          show_age_threshold = 60;
          word_wrap = "yes";
          ignore_newline = "no";
          stack_duplicates = false;
          hide_duplicate_count = "yes";
          show_indicators = "no";
          icon_position = "left";
          icon_theme = "Adwaita-dark";
          sticky_history = "yes";
          history_length = 20;
          history = "ctrl+grave";
          browser = "google-chrome-stable";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          max_icon_size = 64;
        };
      };
    };
  };

  programs = shared-programs // { gpg.enable = true; };

}
