{
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
    parser.add_argument("--socket-path", default="/run/playit/playitd.sock")
    parser.add_argument("--log-path", default=None)
    parser.add_argument("--cert-dir", default=None)
    args = parser.parse_args()

    socket_path = Path(args.socket_path)
    socket_path.parent.mkdir(parents=True, exist_ok=True)
    socket_path.write_text("mock-playitd")

    if args.cert_dir:
        cert_dir = Path(args.cert_dir)
        cert_dir.mkdir(parents=True, exist_ok=True)
        (cert_dir / "mock-acme-account").write_text("mock")

    secret_value = Path(args.secret_path).read_text()
    print(f"Secret value: {secret_value}", flush=True)
    print(f"playitd socket path: {args.socket_path}", flush=True)
    print(f"Log path: {args.log_path}", flush=True)

    HTTPServer(("", 9213), SimpleHTTPRequestHandler).serve_forever()
  ''
