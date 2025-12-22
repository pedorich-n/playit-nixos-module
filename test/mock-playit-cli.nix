{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellScriptBin "mock-playit-cli" ''
  SECRET_PATH=""
  while [[ $# -gt 0 ]]; do
      case "$1" in
          --secret_path) SECRET_PATH="$2"; shift 2;;
          *) shift;;
      esac
  done

  if [[ -z "$SECRET_PATH" ]]; then
      echo "No secret path provided" >&2
      exit 1
  fi

   SECRET_VALUE=$(cat "$SECRET_PATH")
   echo "Secret value: $SECRET_VALUE"

  ${lib.getExe pkgs.simple-http-server} --port 9213
''
