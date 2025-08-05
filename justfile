_build target *args:
    nix build "{{ justfile_directory() + '#' + target }}" {{ if args != "" { '-- ' + args } else { '' } }}

_develop target:
    nix develop "{{ justfile_directory() + '#' + target }}"

_run target *args:
    nix run "{{ justfile_directory() + '#' + target }}" {{ if args != "" { '-- ' + args } else { '' } }}

check:
    nix flake check "{{ justfile_directory() }}"

fmt:
    nix fmt {{ justfile_directory() }}

generate-pre-commit:
    nix develop "{{ justfile_directory() + '#pre-commit' }}"

build-playit:
    nix build "{{ justfile_directory() + '#playit-cli' }}"
