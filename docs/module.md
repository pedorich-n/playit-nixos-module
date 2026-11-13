## services\.playit\.enable

Whether to enable Playit Service\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## services\.playit\.package



The playit package to use\.



*Type:*
package



*Default:*

```nix
pkgs.playit
```



## services\.playit\.logrotate



When enabled, creates a logrotate rule for playit logs\.

**Note:** You must explicitly enable ` services.logrotate ` for this to work\.



*Type:*
boolean



*Default:*

```nix
true
```



## services\.playit\.secretPath



Path to a TOML file containing the playit agent secret\.
Loaded via systemd’s ` LoadCredential ` directive, so the file permissions can be tightened to ` 0400 ` and owned by any user\.



*Type:*
absolute path



*Example:*

```nix
/etc/playit/secret.toml
```


