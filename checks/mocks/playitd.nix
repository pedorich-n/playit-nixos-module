{
  cliSocketPath ? null,
  writeTextFile,
  runtimeShell,
  stdenv,
  simple-http-server,
  lib,
}:
writeTextFile {
  name = "mock-playitd";
  executable = true;
  destination = "/bin/playitd";
  text = ''
    #!${runtimeShell}

    SECRET_PATH=""
    SOCKET_PATH=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --secret-path) SECRET_PATH="$2"; shift 2;;
            --socket-path) SOCKET_PATH="$2"; shift 2;;
            *) shift;;
        esac
    done

    if [[ -z "$SECRET_PATH" ]]; then
        echo "No secret path provided" >&2
        exit 1
    fi

    if [[ -n "$SOCKET_PATH" ]]; then
        mkdir -p "$(dirname "$SOCKET_PATH")"
        echo "mock-playitd" > "$SOCKET_PATH"
    fi

    SECRET_VALUE=$(cat "$SECRET_PATH")
    echo "Secret value: $SECRET_VALUE"

    echo "plyitd socket path: $SOCKET_PATH"
    echo "playit-cli socket path: ${toString cliSocketPath}"

    ${lib.getExe simple-http-server} --port 9213
  '';

  checkPhase = ''
    ${stdenv.shellDryRun} "$target"
  '';
}
