{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.partitions
  ];

  partitions.dev = {
    extraInputsFlake = ../dev;
    extraInputs = {
      inherit (config.partitions.dev.extraInputs.nix-dev-flake.inputs) treefmt-nix pre-commit-hooks;
    };
    module =
      {
        inputs,
        lib,
        ...
      }:
      {
        imports = [
          "${config.partitions.dev.extraInputs.nix-dev-flake}/flake-module.nix"
        ];

        perSystem = {
          treefmt.config = {
            projectRoot = ../.;

            settings = {
              global.excludes = [
                "docs/*"
              ];
            };

          };
          pre-commit.settings = {
            rootSrc = ../.;
          };
        };

        flake.ghaMatrices = {
          cache = inputs.nix-github-actions.lib.mkGithubMatrix {
            checks = lib.mapAttrs (_system: packages: lib.filterAttrs (name: _package: name == "playit") packages) config.flake.packages;
            attrPrefix = "packages";
          };
        };
      };
  };

  partitionedAttrs = {
    devShells = "dev";
    checks = "dev";
    formatter = "dev";
    ghaMatrices = "dev";
  };
}
