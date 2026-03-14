{ config, pkgs, inputs, lib, ... }:

{
  # Hyprland (system enablement)
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };

  # XDG portals
  xdg.portal = {
    enable = true;
    wlr.enable = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Display Manager (greetd + tuigreet)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd Hyprland";
        user = "greeter";
      };
    };
  };
  # Suppress greetd "last session" noise in the journal:
  systemd.services.greetd.serviceConfig.SuppressOkStatusCodes = [ 1 ];

  # Wayland environment (system-wide, applies to all sessions)
  environment.sessionVariables = {
    NIXOS_OZONE_WL  = "1"; # Electron apps use Wayland
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    GDK_BACKEND     = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  # System packages (Wayland stack, available to all users)
  environment.systemPackages = with pkgs; [
    wayland
    wayland-protocols
    wayland-utils
    xwayland
    wl-clipboard
    hyprpaper
    qt5.qtwayland
    qt6.qtwayland
  ];
}
