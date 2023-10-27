{ pkgs }:
with pkgs.python3Packages;
buildPythonPackage {
  pname = "mock-playit-cli";
  version = "0.0.1";
  format = "pyproject";

  src = ./.;

  propagatedBuildInputs = [ setuptools ];

  meta = {
    mainProgram = "mock-playit-cli";
  };
}
