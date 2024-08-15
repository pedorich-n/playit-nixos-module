{ pkgs, playit-agent-source, craneLib, ... }:
let
  toolchain = pkgs.rust-bin.stable.latest.default;
  craneLibWithOverride = craneLib.overrideToolchain toolchain;
in
craneLibWithOverride.buildPackage {
  pname = "playit-cli";
  meta.mainProgram = "playit-cli";
  src = craneLib.cleanCargoSource playit-agent-source;

  strictDeps = true;
  doCheck = false;

  nativeBuildInputs = [
    pkgs.pkg-config
  ];
  buildInputs = [
    pkgs.openssl.dev
  ];
  env = {
    # See: https://github.com/NixOS/nixpkgs/issues/303975
    OPENSSL_NO_VENDOR = true;
  };
}
