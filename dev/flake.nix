{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    # Dev tools
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs@{ flake-parts, systems, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import systems;
    imports = [
      inputs.treefmt-nix.flakeModule
      inputs.pre-commit-hooks.flakeModule
    ];

    perSystem = { config, lib, pkgs, ... }: {
      devShells = {
        pre-commit =
          let
            gitExe = lib.getExe pkgs.git;
          in
          pkgs.mkShell {
            shellHook = ''
              ${config.pre-commit.installationScript}
            
              hooksPath=$(${gitExe} config --local core.hooksPath)
              if [ "$hooksPath" == "../.git/hooks" ]; then
                  ${gitExe} config --local core.hooksPath ".git/hooks"
                  echo "Replaced core.hooksPath with \".git/hooks\""
              fi
            '';
          };
      };

      treefmt.config = {
        projectRootFile = ".root";
        flakeCheck = false;

        programs = {
          # Nix
          nixpkgs-fmt.enable = true;
        };
      };

      pre-commit.settings = {
        rootSrc = lib.mkForce ../.;
        settings.treefmt.package = config.treefmt.build.wrapper;

        hooks = {
          deadnix.enable = true;
          statix.enable = true;

          treefmt.enable = true;
        };
      };
    };

  };
}
