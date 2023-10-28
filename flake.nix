{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
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

    perSystem = { config, lib, pkgs, system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.rust-overlay.overlays.default ];
      };

      packages = {
        playit-cli = pkgs.callPackage ./nix/package.nix { inherit (inputs) playit-agent-source crane; };
        default = config.packages.playit-cli;
        # mock = pkgs.callPackage ./test/mock-playit-cli { };
      };

      checks = {
        test-services-playit = pkgs.callPackage ./test/test-services-playit.nix { };
      };
    };

    flake = {
      nixosModules.default = moduleWithSystem (perSystem@{ config }: { ... }: {
        imports = [ (import ./nix/nixos-module.nix { package = perSystem.config.packages.playit-cli; }) ];
      }
      );
    };
  });
}
