# NixOS module for Playit Agent

This NixOS module provides two things:

- packaged [playit-agent](https://github.com/playit-cloud/playit-agent)
- a service definition to run `playitd` as systemd service

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
    secretPath = config.age.secrets.playit-secret.path;
  };
}
```

### Additional settings

You can configure the port mappings in the [Tunnels](https://playit.gg/account/tunnels) section of the website.

### Obtaining a secret

Run

```bash
❯ nix run github:pedorich-n/playit-nixos-module#playit -- claim generate
```

copy the generated claim code and run

```bash
❯ nix run github:pedorich-n/playit-nixos-module#playit -- claim exchange <claim_code>
```

Follow the instructions on the screen, and approve new agent via browser.

After the agent is claimed it will output its secret to the console. It will look something like this:

```
Open this link to finish setting up playit:
https://playit.gg/claim/XXXXXXXXXX
Program approved. Finishing setup...
74f8XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX6509
```

Create a TOML file with the following structure:

```toml
secret_key = "74f8XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX6509"
```

This file needs to be passed to `services.playit.secretPath`.

It is recommended to use secret manager like [agenix](https://github.com/ryantm/agenix) or [sops](https://github.com/Mic92/sops-nix) to avoid having exposed secret in `/nix/store`

### Documentation

To see latest documentation run

```Bash
nix run github:pedorich-n/playit-nixos-module#docs.serve
```
