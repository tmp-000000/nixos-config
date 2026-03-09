{ config, pkgs, pkgs-unstable, lib, ... }:

{
  programs.waybar = {
    enable = true;
    # waybar reads WAYLAND_DISPLAY from environment — starts correctly under Hyprland
    systemd.enable = true;
    package = pkgs-unstable.waybar;

    settings = [{
      layer    = "top";
      position = "top";
      height = 36;
      spacing = 12;
      margin-top = 8;
      margin-left = 12;
      margin-right = 12;

      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [
        "custom/media"
        "pulseaudio"
        "cpu"
        "memory"
        "temperature"
        "custom/gpu"
        "network"
        "tray"
        "custom/power"
      ];

      "hyprland/workspaces" = {
        disable-scroll  = true;
        all-outputs     = false;
        on-click        = "activate";
        format          = "{icon}";
        format-icons    = {
          "1" = "[1]";
          "2" = "[2]";
          "3" = "[3]";
          "4" = "[4]";
          "5" = "[5]";
          "6" = "[6]";
          "7" = "[7]";
          "8" = "[8]";
          "9" = "[9]";
          "urgent"  = "";
        };
        persistent-workspaces = {};
      };

      "hyprland/window" = {
        max-length      = 60;
        separate-outputs = true;
      };

      clock = {
        timezone       = "Asia/Yekaterinburg";
        format         = " {:%H:%M}";
        format-alt     = " {:%Y-%m-%d %H:%M:%S}";
        tooltip-format = "<big>{:%A %d %B %Y}</big>\n<tt>{calendar}</tt>";
        interval       = 60;
        calendar = {
          mode       = "year";
          mode-mon-col = 3;
          weeks-pos  = "right";
          on-scroll  = 1;
          format = {
            months    = "<span color='#cad3f5'><b>{}</b></span>";
            days      = "<span color='#b8c0e0'>{}</span>";
            weeks     = "<span color='#8bd5ca'>W{}</span>";
            weekdays  = "<span color='#c6a0f6'><b>{}</b></span>";
            today     = "<span color='#ed8796'><b><u>{}</u></b></span>";
          };
        };
      };

      "custom/media" = {
        format = " {}";
        return-type = "json";
        max-length  = 40;
        format-icons = {
          "spotify"       = "";
          "youtube-music" = "";
          "default"       = "󰝚";
        };
        escape = true;
        exec = "${pkgs.playerctl}/bin/playerctl -a metadata --format '{\"text\": \"{{markup_escape(title)}}\", \"tooltip\": \"{{playerName}}: {{markup_escape(title)}}\", \"alt\": \"{{playerName}}\", \"class\": \"{{playerName}}\"}' -F 2>/dev/null";
        on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
      };

      pulseaudio = {
        format            = "{icon} {volume}%";
        format-muted      = "󰝟 Muted";
        format-icons = {
          "headphone"      = "󰋋";
          "hands-free"     = "󰋎";
          "headset"        = "󰋎";
          "default"        = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click          = "${pkgs.pavucontrol}/bin/pavucontrol";
        scroll-step       = 5;
        max-volume        = 150;
        tooltip-format    = "{desc} ({volume}%)";
      };

      cpu = {
        interval = 3;
        format   = "󰍛 {usage}%";
        format-icons = ["󰾅" "󰾆" "󰓅"];
        tooltip  = true;
        on-click = "${pkgs.kitty}/bin/kitty --class btm btm";
      };

      memory = {
        interval = 5;
        format   = "󰘚 {percentage}%";
        tooltip-format = "RAM {used:0.1f}G / {total:0.1f}G";
        on-click = "${pkgs.kitty}/bin/kitty --class btm btm";
      };

      temperature = {
        interval          = 10;
        critical-threshold = 85;
        format            = " {temperatureC}°C";
      };

      "custom/gpu" =  {
        interval          = 3;
        format            = "󰢮 {}%";
        exec              = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
        tooltip           = true;
      };

      network = {
        interval          = 5;
        format-wifi       = "  {signalStrength}%";
        format-ethernet   = "󰈀 {ipaddr}";
        format-disconnected = "󰤮 Offline";
        format-linked     = "󰈀  (no IP)";
        tooltip-format    = "󰈀 {ifname}\n󰩟 {ipaddr}/{cidr}\n  {gwaddr}\n  {bandwidthUpBits}  {bandwidthDownBits}";
      };

      tray = {
        icon-size  = 22;
        spacing    = 10;
        show-passive-items = true;
      };

      "custom/power" = {
        format   = "⏻";
        tooltip  = false;
        on-click = "${pkgs.wlogout}/bin/wlogout -b 5";
      };
    }];

    style = ''
      /* Catppuccin Macchiato */

      @define-color base #24273a;
      @define-color mantle #1e2030;
      @define-color surface0 #363a4f;
      @define-color surface1 #494d64;
      @define-color overlay0 #6e738d;

      @define-color text #cad3f5;
      @define-color subtext #b8c0e0;

      @define-color blue #8aadf4;
      @define-color teal #8bd5ca;
      @define-color mauve #c6a0f6;
      @define-color red #ed8796;
      @define-color yellow #eed49f;
      @define-color peach #f5a97f;

      /* GLOBAL */

      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 17px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      /* BAR */

      window#waybar {
        background: transparent;
        color: @text;
      }

      /* MODULE CONTAINERS */

      .modules-left,
      .modules-center,
      .modules-right {
        background: rgba(36, 39, 58, 0.55);
        border-radius: 14px;
        padding: 6px 14px;
        margin: 0 6px;
      }

      /* WORKSPACES */

      #workspaces {
        background: transparent;
      }

      #workspaces button {
        color: @overlay0;
        padding: 6px 12px;
        margin: 0 4px;
        border-radius: 10px;
        transition: all 0.25s cubic-bezier(.4,0,.2,1);
      }

      #workspaces button:hover {
        background: @surface1;
        color: @text;
      }

      #workspaces button.active {
        background: @teal;
        color: @base;
        font-weight: bold;
      }

      #workspaces button.urgent {
        background: @red;
        color: @base;
      }

      /* WINDOW TITLE */

      #window {
        padding: 0 14px;
        color: @subtext;
        font-style: italic;
      }

      /* CLOCK */

      #clock {
        font-weight: bold;
        color: @blue;
        padding: 0 18px;
      }

      /* MODULES */

      #pulseaudio,
      #cpu,
      #memory,
      #temperature,
      #network,
      #tray,
      #custom-media,
      #custom-power,
      #custom-gpu {
        padding: 0 14px;
      }

      /* COLORS */

      #pulseaudio {
        color: @teal;
      }

      #pulseaudio.muted {
        color: @overlay0;
      }

      #cpu {
        color: @yellow;
      }

      #memory {
        color: @mauve;
      }

      #temperature {
        color: @peach;
      }

      #temperature.critical {
        color: @red;
      }

      #network {
        color: @blue;
      }

      #network.disconnected {
        color: @red;
      }

      #custom-media {
        color: @teal;
        font-style: italic;
      }

      /* POWER BUTTON */

      #custom-power {
        font-size: 18px;
        color: @red;
        padding-right: 10px;
      }

      /* TRAY */

      #tray {
        padding: 0 10px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        color: @peach;
      }
    '';
  };
}
