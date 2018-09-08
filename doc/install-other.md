# Installation

## For Jenkins/CI Worker nodes

A Jenkins/CI worker node should have prepared copies of each profile -- and
running daemon for each profile.

(*These steps were developed on Debian 9.*)

```bash
## Install multiuser nix pkg mgr, per https://nixos.org/nix/manual/#sect-multi-user-installation
sudo apt-get install rsync
sh <(curl https://nixos.org/nix/install) --daemon

## Initialize the min, max, and dfl profiles for user bknix
sudo -i bash
git clone https://github.com/totten/bknix /root/bknix
cd /root/bknix
./bin/install-ci.sh

## Do a trial run
su - totten
eval $(use-ci-bknix dfl)
which php
php --version
# (...and exit...)

## Allow the SSH access for the user. Add SSH keys (and prevent self-modification).
sudo addgroup ssh-user
sudo adduser bknix ssh-user
sudo cp ~totten/.ssh/authorized_keys ~bknix/.ssh/authorized_keys
sudo chown root.root ~bknix/.ssh/authorized_keys
```

## For development/patching

If you're developing a revision to the `bknix.git` project, then you'll need to clone the git repo and work with the
configuration files locally.

```
git clone https://github.com/totten/bknix
```

The quickest way to try out a configuration (like `dfl` or `min` or `max`) is to use `nix-shell`, as in:

```
cd bknix
nix-shell -A dfl
```

Within that shell, you can use commands like `bknix init`, `bknix run`, `composer`, or `civibuild`.

To add/remove/modify the programs in each configuration, you can edit the configuration files (`./default.nix`,
`./profiles/*`, `./pkgs/*`, etc.).  To apply the changes, simply exit `nix-shell` and run it again.  Whenever you run
`nix-shell`, it uses the current config files.

NOTE: `nix-shell` is the easiest way to work on a configuration patch.  However, if you're specifically revising the
installation-process or profile-arrangement, then you *can* install a profile.  Let's recall the installation step
provided to new users in [README.md](../README.md):

```bash
sudo -i nix-env -i -p /nix/var/nix/profiles/bknix-dfl -f 'https://github.com/totten/bknix/archive/master.tar.gz' -E 'f: f.profiles.dfl'
```

Which breaks down as a few parts:

* `sudo -i` means *run the command as `root`*
* `nix-env -i` means *install packages to a live environment*
* `-p /nix/var/nix/profiles/bknix-dfl` means *put the packages in the shared profile `bknix-dfl`*
* `-f 'https://github.com/totten/bknix/archive/master.tar.gz'` means *download the latest configuration file from Github*
* `-E 'f: f.profiles.dfl'` means *get a list of packages by evaluating the configuration file (aliased as `f`) and returning property `f.profiles.dfl`*

For local development, we can change the `-f` option to get the config files from a local source (like `$HOME/bknix`):

```bash
sudo -i nix-env -i -p /nix/var/nix/profiles/bknix-dfl -f $HOME/bknix -E 'f: f.profiles.dfl'
```

or equivalently

```bash
cd $HOME/bknix
sudo -i nix-env -i -p /nix/var/nix/profiles/bknix-dfl -f . -E 'f: f.profiles.dfl'
```