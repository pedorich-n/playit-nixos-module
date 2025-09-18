{ moduleWithSystem, ... }:
{
  flake = {
    nixosModules.default = moduleWithSystem (
      perSystem:
      { ... }:
      {
        imports = [ ../nix/nixos-module.nix ];
        services.playit.package = perSystem.config.packages.playit-cli;
      }
    );
  };
}
