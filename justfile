check-fmt:
    nix flake check ./dev

fmt:
    cd ./dev; nix fmt ../

generate-pre-commit:
    nix develop ./dev#pre-commit