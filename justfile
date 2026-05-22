_build target *args:
    nix build "{{ justfile_directory() + '#' + target }}" {{ args }}

_develop target:
    nix develop "{{ justfile_directory() + '#' + target }}"

_run target *args:
    nix run "{{ justfile_directory() + '#' + target }}" {{ args }}

check:
    nix flake check "{{ justfile_directory() }}"

fmt:
    nix fmt {{ justfile_directory() }}

generate-pre-commit:
    just _develop "pre-commit"

build-playit *args:
    just _build playit "{{ args }}"

place-docs:
    just _build module-docs --json | jq -r '.[0].outputs.out' | xargs -I {} cp --no-preserve=mode,ownership {}/share/doc/nixos/module.md docs/module.md
