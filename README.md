`bknix` is a highly opinionated environment for developing in PHP/JS (esp developing patches/add-ons for CiviCRM and
related CMS's).  It combines system binaries from [nix](https://nixos.org/nix) with a toolchain from
[buildkit](https://github.com/civicrm/civicrm-buildkit) and an unsophisticated process-management script (`bknix`).
All development is done in the current user's local Linux/macOS *without* any virtualization, containerization,
invisible filesystems, special accounts, or magic permissions.  To optimize DB performance, `mysqld` runs in ram-disk.

> __STATUS__: This is currently incomplete.  `bknix` needs to be patched so that (a) `bknix start` launches `php-fpm`
> and (b) the httpd uses `php-fpm`.

## Pre-requisites

* Use Linux or OS X on the local workstation
* Install the [nix package manager](https://nixos.org/nix/)
* Have some basic understanding of:
    * Git
    * PHP/JS development (e.g. `composer`, `npm`)
    * Unix CLI (e.g. `bash`, `PATH`)
    * Process management (e.g. `ps`, `kill`), esp for `httpd` and `mysqld`
    * Filesystem management (e.g. "Disk Utility" on OSX; `umount` on Linux)

## download

```
git clone https://github.com/totten/bknix
```

## Usage

Navigate into the project folder and run `nix-shell`:

```
cd bknix
nix-shell
```

> __Note__: When you first run `nix-shell`, it may download additional tooling.
> This is because I don't really know how to write good `*.nix` files.

This puts you in a CLI development environment with access to various binaries (PHP, NodeJS, Apache, MySQL, etc).  You
can start and stop the services using `bknix`, as in:

```
bknix start
bknix stop
```

When you have the services running, you can create builds, e.g.

```
civibuild create empty
civibuild create dmaster
civibuild create wpmaster
```

## Policies/Opinions

* All services run as the current, logged-in user. This means that files require no special permissions.
* All builds are stored in the `build` folder.
* All builds are given the URL `http://<name>.bknix:8001`.
* All hostnames are registered in `/etc/hosts` using `sudo`.
* MySQL launches on-demand with all-ram-disk-based storage, and it listens on TCP port 3307. (Launching is triggered when calling `amp create`, `civibuild create`, `civibuild reinstall`, `civibuild restore`, or similar).

Some of these policies/opinions can be changed, as described below ("Alternate installation for custom policies")

## Tips

* If you don't already have `git` on your system, patch `default.nix` and add it to the list of `buildInputs`.
  However, if you already have it, then leave the default. (This would prevent potential concerns about different programs managing the same `.git` folders.)
* If you're doing development on the bknix initialization process, use `bknix purge` to produce a clean folder (without any data or config).
* If you want to customize some of the `amp` policies, then:
* When you shutdown, the mysql ramdisk remains in memory. To remove or reset it, unmount it with `umount` (in Linux) or *Disk Utility* (in OS X).

## Alternate installation for custom policies

```bash
## Setup a clean environment
git clone https://github.com/totten/bknix
cd bknix
nix-shell

## Initialize default configuration
bknix init

## Alter the configuration, e.g.
amp config
vi civicrm-buildkit/app/civibuild.conf

## Start servies
bknix start
```
