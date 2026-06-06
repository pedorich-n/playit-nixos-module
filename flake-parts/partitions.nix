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
          checks = inputs.nix-github-actions.lib.mkGithubMatrix {
            inherit (config.flake) checks;
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
