{
  moduleWithSystem,
  ...
}:
{
  flake = {
    nixosModules.default = moduleWithSystem (
      { config }: # flake-parts module inputs
      { lib, ... }: # NixOS module inputs
      {
        imports = [ ../modules/nixos/service.nix ];
        services.playit.package = lib.mkDefault config.packages.playit;
      }
    );
  };
}
