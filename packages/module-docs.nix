{
  localFlake,
  lib,
  nixosOptionsDoc,
  runCommand,
}:
let
  optionsFor =
    modules:
    let
      rawOptions =
        (lib.evalModules {
          modules = [
            {
              _module = {
                check = false;
              };
            }
          ]
          ++ modules;
        }).options;
    in
    builtins.removeAttrs rawOptions [ "_module" ];

  moduleDoc = nixosOptionsDoc {
    options = optionsFor (lib.attrValues localFlake.nixosModules);
    transformOptions =
      opt:
      opt
      // {
        # Clean up declaration sites to not refer to /nix/store/
        declarations = [ ];
      };
  };
in
runCommand "playit-nixos-module-doc" { } ''
  target="$out/share/doc/nixos"
  mkdir -p "$target"

  cp ${moduleDoc.optionsCommonMark} $target/module.md
  cp ${moduleDoc.optionsJSON}/share/doc/nixos/options.json $target/module.json
''
