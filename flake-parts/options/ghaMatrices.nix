{
  lib,
  ...
}:
{
  options = {
    flake.ghaMatrices = lib.mkOption {
      type = with lib.types; lazyAttrsOf raw;
      default = { };
      description = ''
        Github Action matrices.
        Each attribute is a matrix name, and its value is the matrix itself.
      '';
    };
  };
}
