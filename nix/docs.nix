{ lib, pkgs }:
let
  optionsFor = module:
    let
      rawOptions = (lib.evalModules {
        modules = [
          { _module.check = false; }
          module
        ];
      }).options;
    in
    builtins.removeAttrs rawOptions [ "_module" ];

  moduleDoc = pkgs.nixosOptionsDoc {
    options = optionsFor ./nixos-module.nix;
    transformOptions = opt: opt // {
      # Clean up declaration sites to not refer to /nix/store/
      declarations = [ ];
    };
  };
in
pkgs.stdenvNoCC.mkDerivation (finalAttrs:
{
  src = ./.;
  name = "playit-nixos-module.doc";

  nativeBuildInputs = with pkgs; [ less glow ];

  installPhase = ''
    mkdir -p $out/docs
    cp ${moduleDoc.optionsCommonMark} $out/docs/module.md
  '';

  passthru.serve = pkgs.writeShellScriptBin "serve" ''
    set -euo pipefail

    ${pkgs.glow}/bin/glow -p ${finalAttrs.finalPackage.out}/docs/module.md
  '';
})
