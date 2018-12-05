# Extra administrative tasks

## Updating binary caches

```
cd pkgs
nix-build
nix copy --to file://$HOME/nix-export -f default.nix
rsync -va --progress --ignore-existing $HOME/nix-export/./ PUBLIC-SERVER:/var/www/bknix/./
```
