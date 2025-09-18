{ inputs, config, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.partitions
  ];

  partitions.dev = {
    extraInputsFlake = ../dev;
    extraInputs = {
      inherit (config.partitions.dev.extraInputs.nix-dev-flake.inputs) treefmt-nix pre-commit-hooks;
    };
    module = {
      imports = [
        "${config.partitions.dev.extraInputs.nix-dev-flake}/flake-module.nix"
      ];

      perSystem = {
        treefmt.config = {
          projectRoot = ../.;

          settings = {
            formatter.deadnix.excludes = [
              "flake-parts/nixosModules.nix"
            ];
          };
        };
        pre-commit.settings = {
          rootSrc = ../.;
        };
      };

    };
  };

  partitionedAttrs = {
    devShells = "dev";
    checks = "dev";
    formatter = "dev";
  };
}
