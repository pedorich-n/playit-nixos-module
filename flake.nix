{
  nixConfig = {
    extra-substituters = [ "https://playit-nixos-module.cachix.org" ];
    extra-trusted-public-keys = [ "playit-nixos-module.cachix.org-1:22hBXWXBbd/7o1cOnh+p0hpFUVk9lPdRLX3p5YSfRz4=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    playit-agent-source = {
      url = "github:playit-cloud/playit-agent";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } ({ moduleWithSystem, ... }: {
    systems = import inputs.systems;

    perSystem = { config, pkgs, system, ... }:
      let
        craneLib = inputs.crane.mkLib pkgs;
      in
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.rust-overlay.overlays.default ];
        };

        packages = {
          playit-cli = pkgs.callPackage ./nix/package.nix { inherit (inputs) playit-agent-source; inherit craneLib; };
          default = config.packages.playit-cli;
          docs = pkgs.callPackage ./nix/docs.nix { };
          # mock = pkgs.callPackage ./test/mock-playit-cli { };
        };

        checks = {
          test-services-playit = pkgs.callPackage ./test/test-services-playit.nix { };
        };
      };

    flake = {
      nixosModules.default = moduleWithSystem (perSystem@{ config }: { ... }: {
        imports = [ ./nix/nixos-module.nix ];
        services.playit.package = perSystem.config.packages.playit-cli;
      });
    };
  });
}
