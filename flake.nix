{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";

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

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, importApply, self, ... }: {
    systems = [ "x86_64-linux" ];

    perSystem = { config, lib, pkgs, system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.rust-overlay.overlays.default ];
      };

      packages = {
        playit-cli = pkgs.callPackage ./nix/package.nix { inherit (inputs) playit-agent-source crane; };
        default = config.packages.playit-cli;
      };
    };

    flake = {
      nixosModules.default = importApply ./nix/nixos-module.nix { localFlake = self; inherit withSystem; };
    };
  });
}
