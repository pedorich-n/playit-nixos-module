{ pkgs, playit-agent-source, crane, ... }:
let
  toolchain = pkgs.rust-bin.stable.latest.default;
  craneLib = (crane.mkLib pkgs).overrideToolchain toolchain;
in
craneLib.buildPackage {
  pname = "playit-cli";
  src = craneLib.cleanCargoSource playit-agent-source;
  strictDeps = true;
  doCheck = false;
}