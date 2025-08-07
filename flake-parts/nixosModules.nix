{ moduleWithSystem, ... }:
{
  flake = {
    nixosModules.default = moduleWithSystem (
      perSystem@{ config }:
      { ... }:
      {
        imports = [ ../nix/nixos-module.nix ];
        services.playit.package = perSystem.config.packages.playit-cli;
      }
    );
  };
}
