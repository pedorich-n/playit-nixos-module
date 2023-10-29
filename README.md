# NixOS module for Playit Agent

This NixOS module provides two things:
- packaged [playit-agent](https://github.com/playit-cloud/playit-agent) using [crane](https://crane.dev/)
- a service defintion to run `playit-agent` as systemd service


## Usage

Add this module to `flake.nix`:
```Nix
inputs = {
    ...
    playit-nixos-module.url = "github:pedorich-n/playit-nixos-module";
}
```

Import module: 
```Nix
    nixosConfigurations = {
      example = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.playit-nixos-module.nixosModules.default
          ./configuration.nix
        ];
      };
    };
```

Setup service:
```Nix
{ config, ... }: {
  services.playit = {
    enable = true;
    user = "playit";
    group = "playit";
    secretPath = config.age.secrets.playit-secret.path;
    runOverride = {
      "890e3610-26cd-4e2b-b161-7cf0e4f69148" = [{ port = 8080; }];
      "177485db-47aa-4fa9-9ccf-411ab761b9f0" = [{ ip = 192.168.1.1; port = 9000; }];
    };
  };
}
```
