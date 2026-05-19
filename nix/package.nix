{
  cliSocketPath ? null,
  fetchFromGitHub,
  rustPlatform,
  makeWrapper,
  lib,
}:
let
  # Windows-specific packages
  packagesToExclude = [
    "playitd-service"
    "playitd-windows-setup"
    "playitd-tray"
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "playit";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "playit-cloud";
    repo = "playit-agent";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-fmyiOr5TP5PNt3FCSR+E7atoDVCocLiHgxhP/FQwl9g=";
  };

  cargoHash = "sha256-gbXqg13n8UeGsGeuXsYFcVfBeCtiHUh2eMjiswRuLSE=";

  cargoBuildFlags = [
    "--workspace"
  ]
  ++ lib.map (pkg: "--exclude ${pkg}") packagesToExclude;

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    wrapProgram ${placeholder "out"}/bin/playit-cli \
      --set-default PLAYIT_SOCKET_PATH "${if cliSocketPath != null then cliSocketPath else "/run/playit/playit.sock"}" \
      --add-flags '--socket-path="''${PLAYIT_SOCKET_PATH}"'
  '';

  strictDeps = true;
  # Requires internet access
  doCheck = false;

  meta = {
    mainProgram = "playit-cli";
    description = "Playit allows you to expose game servers running on your local machine to the internet";
    homepage = "https://github.com/playit-cloud/playit-agent";
    changelog = "https://github.com/playit-cloud/playit-agent/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = lib.sourceTypes.fromSource;
  };
})
