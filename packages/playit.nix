{
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
  lib,
  stdenv,
  cacert,
  libxcb,
  libxkbcommon,
  patchelf,
  vulkan-loader,
  wayland,
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
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "playit-cloud";
    repo = "playit-agent";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-yAQvEJCIBXgwNg6x1MR5kEPpYgGoiO81RCI+q5fa3/c=";
  };

  cargoHash = "sha256-rK0pBsx9y+jXV2lZJpkwonsKBccl6OEuOeuK2P/fZuA=";

  cargoBuildFlags = [
    "--workspace"
  ]
  ++ lib.map (pkg: "--exclude ${pkg}") packagesToExclude;

  env = {
    # agent_core's TLS tests build a rustls client and fail when the CA store is empty.
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libxcb
    libxkbcommon
  ];

  strictDeps = true;
  doCheck = true;

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux patchelf;
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf $out/bin/playit-gui --add-rpath ${
      lib.makeLibraryPath [
        vulkan-loader
        wayland
      ]
    }
  '';

  nativeCheckInputs = [
    cacert
    versionCheckHook
  ];

  doInstallCheck = true;
  versionCheckProgramArg = "version";

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
