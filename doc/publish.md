# Updating binary caches (cachix)

```
cd bknix
export CACHIX_SIGNING_KEY=...fixme...
nix-build -E 'let p=import ./profiles; in builtins.attrValues p' | sort -u | cachix push bknix
```

# Updating binary caches (bknix.think.hm)

```
cd bknix/pkgs
nix-build
nix copy --to file://$HOME/nix-export -f default.nix
rsync -va --progress --ignore-existing $HOME/nix-export/./ myuser@myhost:/var/www/bknix/./
```
