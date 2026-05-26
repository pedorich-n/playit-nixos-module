{
  cliSocketPath ? null,
  writers,
}:
writers.writePython3Bin "playitd"
  {
    # Not the nix flake, but Python's flake8
    flakeIgnore = [
      "E501" # Line too long
    ];
  }
  ''
    import argparse
    from http.server import HTTPServer, SimpleHTTPRequestHandler
    from pathlib import Path

    parser = argparse.ArgumentParser()
    parser.add_argument("--secret-path", required=True)
    parser.add_argument("--socket-path", default=None)
    parser.add_argument("--log-path", default=None)
    args = parser.parse_args()

    if args.socket_path:
        socket_path = Path(args.socket_path)
        socket_path.parent.mkdir(parents=True, exist_ok=True)
        socket_path.write_text("mock-playitd")

    secret_value = Path(args.secret_path).read_text()
    print(f"Secret value: {secret_value}", flush=True)
    print(f"playitd socket path: {args.socket_path}", flush=True)
    print("playt-cli overriden socket path: ${toString cliSocketPath}", flush=True)
    print(f"Log path: {args.log_path}", flush=True)

    HTTPServer(("", 9213), SimpleHTTPRequestHandler).serve_forever()
  ''
