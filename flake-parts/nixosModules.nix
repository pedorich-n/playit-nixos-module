{ moduleWithSystem, ... }:
{
  flake = {
    nixosModules.default = moduleWithSystem (
      perSystem@{ config }: # NOTE: only explicitly named parameters will be in perSystem
      { ... }:
      {
        imports = [ ../nix/nixos-module.nix ];
        services.playit.package = perSystem.config.packages.playit-cli;
      }
    );
  };
}
