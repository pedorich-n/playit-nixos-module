# NixOS module for Playit Agent

This NixOS module provides two things:
- packaged [playit-agent](https://github.com/playit-cloud/playit-agent) using [crane](https://crane.dev/)
- a service defintion to run `playit-agent` as systemd service


## Usage

Example `flake.nix`:
```Nix
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

### Obtaining a secret

Run 
```Bash
nix run github:pedorich-n/playit-nixos-module#playit-cli -- claim generate
```

This will output a code, use this code in next command
```Bash
nix run github:pedorich-n/playit-nixos-module#playit-cli -- claim exchange <code>
```


Follow the link and approve the agent on the website. After that `plait-cli` will output a secret to the console.
Use this secret to create a TOML file like
```TOML
secret_key = "<secret>"
```

It is recommended to use secret manager like [agenix](https://github.com/ryantm/agenix) or [sops](https://github.com/Mic92/sops-nix) to avoid having exposed secret in `/nix/store`


### Documentation
To see latest documentation run
```Bash
nix run github:pedorich-n/playit-nixos-module#docs.serve
```