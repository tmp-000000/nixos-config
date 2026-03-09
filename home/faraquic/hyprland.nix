{ config, pkgs, inputs, lib, ... }:

let
  # Catppuccin Macchiato palette (used in hyprland borders)
  mauve   = "c6a0f6";
  teal    = "8bd5ca";
  surface0 = "363a4f";
  base    = "24273a";
in
{
  # Hyprland (user config)
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    systemd.enable = true;   # import WAYLAND_DISPLAY etc. into systemd user session

    extraConfig = ''
      # Monitor
      # Set your resolution/refresh rate here. "preferred" = auto-detect.
      monitor = , preferred, auto, 1

      # NVIDIA env (duplicated here for Hyprland's own env system)
      env = LIBVA_DRIVER_NAME,nvidia
      env = GBM_BACKEND,nvidia-drm
      env = __GLX_VENDOR_LIBRARY_NAME,nvidia
      env = WLR_NO_HARDWARE_CURSORS,1
      env = XCURSOR_SIZE,24
      env = XCURSOR_THEME,catppuccin-macchiato-dark-cursors

      # Autostart
      # Services managed by systemd (home-manager) start automatically:
      # waybar, dunst, hypridle, hyprpaper, wlsunset, avizo
      exec-once = nm-applet --indicator
      exec-once = wl-paste --type text  --watch cliphist store
      exec-once = wl-paste --type image --watch cliphist store
      exec-once = wl-clip-persist --clipboard both
      exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1

      # General
      general {
        gaps_in      = 5
        gaps_out     = 10
        border_size  = 2
        col.active_border   = rgba(${teal}ee) rgba(${mauve}ee) 45deg
        col.inactive_border = rgba(${surface0}aa)
        layout       = dwindle
        allow_tearing = false
      }

      # Decoration
      decoration {
        rounding = 10
        active_opacity   = 1.0
        inactive_opacity = 0.95

        blur {
          enabled  = true
          size     = 8
          passes   = 2
          new_optimizations = true
          xray = true
          vibrancy = 0.17
        }

        shadow {
          enabled      = true
          range        = 10
          render_power = 3
          color        = rgba(${base}cc)
        }
      }

      # Animations
      animations {
        enabled = true
        bezier  = smooth,  0.05, 0.9,  0.1,  1.05
        bezier  = linear,  0.0,  0.0,  1.0,  1.0
        bezier  = snap,    0.25, 1.0,  0.5,  1.0

        animation = windows,    1, 6,  smooth
        animation = windowsOut, 1, 5,  default, popin 80%
        animation = border,     1, 8,  default
        animation = borderangle,1, 80, linear, loop
        animation = fade,       1, 5,  default
        animation = workspaces, 1, 5,  snap
      }

      # Layouts
      dwindle {
        pseudotile    = true
        preserve_split = true
      }

      # Input
      input {
        kb_layout  = us,ru
        kb_options = grp:alt_shift_toggle
        follow_mouse = 1
        sensitivity  = 0
        accel_profile = flat
      }

      # Misc
      misc {
        force_default_wallpaper = 0
        disable_hyprland_logo   = true
        disable_splash_rendering = true
      }

      # Keybinds
      $mod = SUPER

      # Core
      bind = $mod,       Return, exec, kitty
      bind = $mod,       Q,      killactive
      bind = $mod SHIFT, Q,      exit
      bind = $mod,       E,      exec, thunar
      bind = $mod,       V,      togglefloating
      bind = $mod,       F,      fullscreen
      bind = $mod,       P,      pseudo

      # Special workspace
      bind = $mod,       S,      togglespecialworkspace
      bind = $mod SHIFT, S,      movetoworkspace, special

      # Launcher
      bind = $mod,       R,      exec, rofi -show drun
      bind = $mod,       Tab,    exec, rofi -show window
      bind = $mod,       X,      exec, rofi -show run
      
      # Clipboard history via rofi
      bind = $mod,       C,      exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy

      # Lock / logout
      bind = $mod,       L,      exec, hyprlock
      bind = $mod SHIFT, L,      exec, wlogout

      # Color picker
      bind = $mod SHIFT, C,      exec, hyprpicker -a

      # Screenshot
      bind = ,           Print,  exec, grim -g "$(slurp)" - | swappy -f -
      bind = $mod,       Print,  exec, grim - | swappy -f -
      bind = $mod SHIFT, Print,  exec, grim -g "$(slurp)" - | wl-copy

      # Screen recorder (toggle)
      bind = $mod SHIFT, R,      exec, wl-screenrec -o ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4 || pkill wl-screenrec

      # Volume (using wpctl + avizo OSD)
      binde = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ && volumectl up
      binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && volumectl down
      bind  = , XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

      # Brightness (using brightnessctl + avizo OSD)
      binde = , XF86MonBrightnessUp,   exec, brightnessctl set +5% && lightctl up
      binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-  && lightctl down

      # Media
      bind = , XF86AudioPlay,  exec, playerctl play-pause
      bind = , XF86AudioNext,  exec, playerctl next
      bind = , XF86AudioPrev,  exec, playerctl previous

      # Focus
      bind = $mod, left,  movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up,    movefocus, u
      bind = $mod, down,  movefocus, d

      # Move windows
      bind = $mod SHIFT, left,  movewindow, l
      bind = $mod SHIFT, right, movewindow, r
      bind = $mod SHIFT, up,    movewindow, u
      bind = $mod SHIFT, down,  movewindow, d

      # Resize with mouse
      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow

      # Workspaces 1–9
      ${lib.concatStringsSep "\n" (map (n: ''
        bind = $mod,       ${toString n}, workspace,       ${toString n}
        bind = $mod SHIFT, ${toString n}, movetoworkspace, ${toString n}
      '') (lib.range 1 9))}

      # Window Rules
      windowrule = float on, match:class ^(pavucontrol)$
      windowrule = float on, match:class ^(nm-connection-editor)$
      windowrule = float on, match:class ^(nwg-look)$
      windowrule = float on, match:title ^(Picture-in-Picture)$
      windowrule = size 900 600, match:class ^(pavucontrol)$

      # Fix for screen sharing (xwaylandvideobridge)
      windowrule = opacity 0.0 override, match:class ^(xwaylandvideobridge)$
      windowrule = no_anim on, match:class ^(xwaylandvideobridge)$
      windowrule = no_initial_focus on, match:class ^(xwaylandvideobridge)$
      windowrule = no_focus on, match:class ^(xwaylandvideobridge)$
    '';
  };

  # Hypridle
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd    = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd            = "pidof hyprlock || hyprlock";
      };
      listener = [
        # Dim after 4 min
        {
          timeout  = 240;
          on-timeout = "brightnessctl -s set 20%";
          on-resume  = "brightnessctl -r";
        }
        # Lock after 5 min
        {
          timeout    = 300;
          on-timeout = "hyprlock";
        }
        # Display off after 10 min
        {
          timeout    = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume  = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # Hyprlock
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor         = true;
        grace               = 5;
      };
      background = [{
        monitor = "";
        path    = "screenshot"; # blurs current screen
        blur_size   = 7;
        blur_passes = 3;
        brightness  = 0.8;
        contrast    = 0.9;
        vibrancy    = 0.2;
      }];
      input-field = [{
        monitor    = "";
        size       = "250, 50";
        position   = "0, -80";
        halign     = "center";
        valign     = "center";
        outline_thickness  = 2;
        dots_size          = 0.33;
        dots_spacing       = 0.15;
        outer_color        = "rgb(363a4f)";  # surface0
        inner_color        = "rgb(24273a)";  # base
        font_color         = "rgb(cad3f5)";  # text
        fade_on_empty      = true;
        placeholder_text   = "<i>Password</i>";
        check_color        = "rgb(8bd5ca)";  # teal
        fail_color         = "rgb(ed8796)";  # red
        fail_text          = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
      }];
      label = [
        # Clock
        {
          monitor  = "";
          text     = "cmd[update:1000] echo \"$(date +\"%H:%M\")\"";
          color    = "rgba(cad3f5ff)";
          font_size    = 72;
          font_family  = "JetBrainsMono Nerd Font Mono Bold";
          position     = "0, 200";
          halign       = "center";
          valign       = "center";
        }
        # Date
        {
          monitor  = "";
          text     = "cmd[update:60000] echo \"$(date +\"%A, %B %d\")\"";
          color    = "rgba(b8c0e0ff)"; # subtext1
          font_size    = 18;
          font_family  = "JetBrainsMono Nerd Font Mono";
          position     = "0, 110";
          halign       = "center";
          valign       = "center";
        }
      ];
    };
  };

  # Hyprpaper
  services.hyprpaper = {
    enable = true;
    settings = {
      # Add your wallpaper path here. Default: ~/Pictures/wallpaper.png
      preload  = [ "~/Pictures/wallpaper.png" ];
      wallpaper = [ ", ~/Pictures/wallpaper.png" ];
      splash    = false;
    };
  };

  # Wlogout
  xdg.configFile."wlogout/layout".text = ''
    {
        "label" : "lock",
        "action" : "hyprlock",
        "text" : "Lock",
        "keybind" : "l"
    }
    {
        "label" : "hibernate",
        "action" : "systemctl hibernate",
        "text" : "Hibernate",
        "keybind" : "h"
    }
    {
        "label" : "logout",
        "action" : "loginctl terminate-user $USER",
        "text" : "Logout",
        "keybind" : "e"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shutdown",
        "keybind" : "s"
    }
    {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "Suspend",
        "keybind" : "u"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r"
    }
  '';

  xdg.configFile."wlogout/style.css".text = ''
    * {
      background-image: none;
      font-family: "JetBrainsMono Nerd Font";
    }
    window {
      background-color: rgba(36, 39, 58, 0.85);
    }
    button {
      color: #cad3f5;
      background-color: #363a4f;
      border-radius: 12px;
      margin: 8px;
      padding: 12px;
      font-size: 14px;
      transition: background-color 0.2s;
    }
    button:hover {
      background-color: #494d64;
      color: #8bd5ca;
    }
    button:focus {
      background-color: #8bd5ca;
      color: #24273a;
    }
  '';

  # Polkit agent (user service)
  systemd.user.services.polkit-gnome = {
    Unit = {
      Description = "GNOME Polkit authentication agent";
      After       = [ "graphical-session.target" ];
      PartOf      = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart  = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart    = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
