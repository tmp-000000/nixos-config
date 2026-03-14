{ config, pkgs, lib, ... }:

{
  # GTK theme: Catppuccin Macchiato + Teal accent
  gtk = {
    enable = true;

    theme = {
      name = "catppuccin-macchiato-teal-standard";
      package = pkgs.catppuccin-gtk.override {
        variant = "macchiato";
        accents = [ "teal" ];
        size    = "standard";
        tweaks  = [ "normal" ];
      };
    };

    iconTheme = {
      package = pkgs.colloid-icon-theme;
      name    = "Colloid-teal-dark";
    };

    cursorTheme = {
      name    = "catppuccin-macchiato-dark-cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
      size    = 24;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Qt theme
  qt = {
    enable = true;
    platformTheme.name = "gtk";   # use GTK theme for Qt too
    style = {
      name = "adwaita-dark";
      package = pkgs.qt6Packages.qt6ct;
    };
  };

  # Cursor (X11 legacy)
  home.pointerCursor = {
    name    = "catppuccin-macchiato-dark-cursors";
    package = pkgs.catppuccin-cursors.macchiatoDark;
    size    = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Icon pack: Numix Circle (secondary — for apps without Colloid icons)
  home.packages = with pkgs; [
    numix-icon-theme-circle   # circular icon variant
    papirus-icon-theme        # broad coverage fallback
  ];

  # GTK settings via dconf (takes effect at runtime)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme  = "prefer-dark";
      gtk-theme     = "catppuccin-macchiato-teal-standard";
      icon-theme    = "Colloid-teal-dark";
      cursor-theme  = "catppuccin-macchiato-dark-cursors";
      cursor-size   = 24;
      font-name     = "Noto Sans 11";
      document-font-name = "Noto Sans 11";
      monospace-font-name = "JetBrainsMono Nerd Font Mono 11";
    };
  };

  # nwg-look config (GUI theme editor for GTK under Wayland)
  # nwg-look stores its config in ~/.config/nwg-look/config
  xdg.configFile."nwg-look/config".text = ''
    gsettings_color_scheme=prefer-dark
    gtk_theme=catppuccin-macchiato-teal-standard
    icon_theme=Colloid-teal-dark
    cursor_theme=catppuccin-macchiato-dark-cursors
    cursor_size=24
    font_name=Noto Sans 11
  '';
}
