{
  playit-agent-source,
  rustPlatform,
  lib,
  ...
}:
let
  src = lib.cleanSource playit-agent-source;
  cargoLock = "${src}/Cargo.lock";
  cargoToml = lib.importTOML "${src}/Cargo.toml";
in
rustPlatform.buildRustPackage {
  pname = "playit-agent";
  meta.mainProgram = "playit-cli";
  inherit (cargoToml.workspace.package) version;

  inherit src;
  cargoLock = {
    lockFile = cargoLock;
  };

  strictDeps = true;
  # Requires internet access
  doCheck = false;
}
