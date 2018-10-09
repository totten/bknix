# Updating binary caches

```
cd bknix/pkgs
nix-build
nix copy --to file://$HOME/nix-export -f default.nix
rsync -va --progress --ignore-existing $HOME/nix-export/./ myuser@myhost:/var/www/bknix/./
```
