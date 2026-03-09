{ config, pkgs, pkgs-unstable, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nvidia.nix
    ../../modules/hyprland.nix
    ../../modules/gaming.nix
    ../../modules/development.nix
    ../../modules/secrets.nix
  ];

  # Bootloader
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 16;
      editor = false;
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  # initrd: LUKS unlock
  boot.initrd = {
    availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

    luks.devices = {
      cryptroot = {
        allowDiscards = true;
        bypassWorkqueues = true;
      };
      crypthome = {
        keyFile = "/etc/luks/crypthome.key";
        keyFileSize = 4096;
        allowDiscards = false;
      };
    };

    secrets = {
      "/etc/luks/crypthome.key" = /etc/luks/crypthome.key;
    };
  };

  # Kernel
  # Zen kernel: lower latency, better desktop responsiveness.
  # If NVIDIA driver fails to build for zen, fall back to pkgs.linuxPackages_6_12.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.udev.log_level=3"
    "intel_pstate=active"
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  # Needed for Plymouth password prompt to work with LUKS
  boot.initrd.systemd.enable = true;

  # Plymouth (graphical boot)
  boot.plymouth = {
    enable = true;
    theme = "catppuccin-macchiato";
    themePackages = [ pkgs.catppuccin-plymouth ];
  };

  boot.tmp.useTmpfs = true;

  # Swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    networkmanager.dns = "systemd-resolved";
    firewall.enable = true;
  };

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    llmnr = "false";
    extraConfig = ''
      DNS=178.46.167.178#dns.faraquic.tech
      FallbackDNS=1.1.1.1#cloudflare-dns.com
      DNSOverTLS=yes
      Domains=~.
    '';
  };

  # Locale & Time
  time.timeZone = "Asia/Yekaterinburg";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT    = "ru_RU.UTF-8";
    LC_MONETARY       = "ru_RU.UTF-8";
    LC_NAME           = "ru_RU.UTF-8";
    LC_NUMERIC        = "ru_RU.UTF-8";
    LC_PAPER          = "ru_RU.UTF-8";
    LC_TELEPHONE      = "ru_RU.UTF-8";
    LC_TIME           = "ru_RU.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Users
  users.users.faraquic = {
    isNormalUser = true;
    description = "Faraquic!";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "gamemode" "podman" ];
    shell = pkgs.fish;
  };

  security.sudo.wheelNeedsPassword = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;      # home packages use system nixpkgs (no separate eval)
    useUserPackages = true;    # install to /etc/profiles/per-user instead of ~/.nix-profile
    extraSpecialArgs = {
      inherit pkgs-unstable;
      inherit inputs;
    };
    users.faraquic = { pkgs, ... }: {
      imports = [
        ../../home/faraquic/default.nix
      ];
    };
  };

  # System packages (minimal — only what root/admin needs)
  environment.systemPackages = with pkgs; [
    git curl wget file which nano
    lsof psmisc strace pciutils usbutils smartmontools
    parted gptfdisk cryptsetup btrfs-progs snapper
    iperf3
  ];

  programs.fish.enable = true; # needed to add fish to /etc/shells

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.defaultFonts = {
      serif     = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "JetBrainsMono Nerd Font Mono" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };

  # Sound (PipeWire)
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Thunar
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;   # virtual filesystem (MTP, SMB, trash, etc.)
  services.tumbler.enable = true; # thumbnail service for Thunar

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Snapper
  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";
    configs = {
      root = {
        SUBVOLUME = "/";
        ALLOW_USERS = [ "faraquic" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY  = "6";
        TIMELINE_LIMIT_DAILY   = "7";
        TIMELINE_LIMIT_WEEKLY  = "4";
        TIMELINE_LIMIT_MONTHLY = "3";
        TIMELINE_LIMIT_YEARLY  = "0";
      };
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "faraquic" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY  = "6";
        TIMELINE_LIMIT_DAILY   = "14";
        TIMELINE_LIMIT_WEEKLY  = "4";
        TIMELINE_LIMIT_MONTHLY = "6";
        TIMELINE_LIMIT_YEARLY  = "1";
      };
    };
  };

  services.fstrim = { enable = true; interval = "weekly"; };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}