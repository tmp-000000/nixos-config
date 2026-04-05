{ config, pkgs, pkgs-unstable, lib, ... }:

{
  # Python (system-level, for scripts/tooling)
  environment.systemPackages = with pkgs; [
    python3
    python3Packages.pip
    uv

    docker-compose  # CLI only — works with Podman socket via dockerCompat

    pkgs-unstable.gcc pkgs-unstable.clang pkgs-unstable.clang-tools pkgs-unstable.lld
  ];

  # Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # provides `docker` alias pointing to podman
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # direnv + nix-direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # nix-ld (run unpatched ELF binaries — JetBrains IDEs, etc.)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      curl
      glib
      gtk3
      expat
      libGL
    ];
  };

  environment.variables = {
    EDITOR = "nano";
    VISUAL = "nano";
    PAGER  = "less";
  };
}
