{
  description = "NixOS configuration — Faraquic";

  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, disko, home-manager, sops-nix, hyprland, ... }@inputs:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs pkgs-unstable;
        vscode-extensions = inputs.nix-vscode-extensions.extensions.${system}.vscode-marketplace;
      };
      modules = [
        { nixpkgs.hostPlatform = system; }
        { nixpkgs.overlays = [ inputs.nur.overlays.default ]; }
        
        disko.nixosModules.disko
        ./disko.nix
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops

        ./hosts/desktop/configuration.nix
      ];
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        pkgs-unstable.rustc
        pkgs-unstable.cargo
        pkgs-unstable.rust-analyzer
        pkgs-unstable.rustfmt
        pkgs-unstable.clippy
        pkgs-unstable.pkg-config
        pkgs-unstable.clang
        pkgs-unstable.lld
        openssl
      ];

      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
  };
}
