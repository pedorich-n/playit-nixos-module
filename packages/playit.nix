{
  cliSocketPath ? "/run/playit/playit.sock",
  fetchFromGitHub,
  rustPlatform,
  makeBinaryWrapper,
  versionCheckHook,
  lib,
}:
let
  # Windows-specific packages
  packagesToExclude = [
    "playitd-windows-setup"
    "playitd-tray"
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "playit";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "playit-cloud";
    repo = "playit-agent";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-r0Rbdiv8vMXMwjsD/sRnrzT7BATheU7DJ1qgQWATAwM=";
  };

  cargoHash = "sha256-Wf8eJTSTAxo56t/ImRXzn7wl1mo4y4D/TQ5JHGoPCrc=";

  cargoBuildFlags = [
    "--workspace"
  ]
  ++ lib.map (pkg: "--exclude ${pkg}") packagesToExclude;

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  postInstall = ''
    wrapProgram ${placeholder "out"}/bin/playit-cli \
      --set-default PLAYIT_SOCKET_PATH ${lib.escapeShellArg cliSocketPath} \
      --add-flags '--socket-path="''${PLAYIT_SOCKET_PATH}"'
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgramArg = "version";

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
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
