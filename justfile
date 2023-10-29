check-fmt:
    cd ./dev; nix flake check

fmt:
    cd ./dev; nix fmt ../

generate-pre-commit:
    cd ./dev; nix develop .#pre-commit