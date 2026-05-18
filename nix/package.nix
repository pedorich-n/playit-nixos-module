{
  playit-agent-source,
  rustPlatform,
  makeWrapper,
  lib,
  ...
}:
let
  src = lib.cleanSource playit-agent-source;
  cargoLock = "${src}/Cargo.lock";
  cargoToml = lib.importTOML "${src}/Cargo.toml";

  # Windows-specific packages
  packagesToExclude = [
    "playitd-service"
    "playitd-windows-setup"
    "playitd-tray"
  ];
in
rustPlatform.buildRustPackage {
  pname = "playit";
  meta.mainProgram = "playit-cli";
  inherit (cargoToml.workspace.package) version;

  inherit src;
  cargoLock = {
    lockFile = cargoLock;
  };

  cargoBuildFlags = [
    "--workspace"
  ]
  ++ lib.map (pkg: "--exclude ${pkg}") packagesToExclude;

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    wrapProgram ${placeholder "out"}/bin/playit-cli \
      --add-flag '--socket-path=/var/run/playit/playit.sock'
  '';

  strictDeps = true;
  # Requires internet access
  doCheck = false;
}
