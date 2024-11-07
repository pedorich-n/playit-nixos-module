# NixOS module for Playit Agent

This NixOS module provides two things:

- packaged [playit-agent](https://github.com/playit-cloud/playit-agent) using [crane](https://crane.dev/)
- a service defintion to run `playit-agent` as systemd service

## Usage

Example `flake.nix`:

```Nix
{
  # Optional step. Binary cache to improve the build time
  nixConfig = {
    extra-substituters = [ "https://playit-nixos-module.cachix.org" ];
    extra-trusted-public-keys = [ "playit-nixos-module.cachix.org-1:22hBXWXBbd/7o1cOnh+p0hpFUVk9lPdRLX3p5YSfRz4=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    playit-nixos-module.url = "github:pedorich-n/playit-nixos-module";
  }

  output = { nixpkgs, playit-nixos-module }: {
    nixosConfigurations = {
      example = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          playit-nixos-module.nixosModules.default
          ./configuration.nix
        ];
      };
    };
  }
}
```

Setup service:

```Nix
{ config, ... }: {
  services.playit = {
    enable = true;
    user = "playit";
    group = "playit";
    secretPath = config.age.secrets.playit-secret.path;
  };
}
```

### Obtaining a secret

Run

```Bash
nix run github:pedorich-n/playit-nixos-module#playit-cli -- start
```

The program will prompt the link to the website to claim the agent. Follow the instructions on the website.

After the agent is claimed it will start running and serving the tunnels. You can exit the program at this point.
The TOML file containing the secret for newly claimed agent should be at `~/.config/playit_gg/playit.toml`. This file needs to be passed as `secretPath`.

It is recommended to use secret manager like [agenix](https://github.com/ryantm/agenix) or [sops](https://github.com/Mic92/sops-nix) to avoid having exposed secret in `/nix/store`

### Documentation

To see latest documentation run

```Bash
nix run github:pedorich-n/playit-nixos-module#docs.serve
```
