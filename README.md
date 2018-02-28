## Installation

First, install the [nix package manager](https://nixos.org/nix/).

Then:

```
git clone https://github.com/totten/bknix
```

## Usage

Navigate into the project folder and run `nix-shell`:

```
cd bknix
nix-shell
```

This puts you in a CLI development environment with access to various
binaries (Apache, MySQL, NodeJS, etc).  You can start and stop the services using `bknix`, as in:

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

## Policy

* All services run as the current, logged-in user. This means that files require no special permissions.
* All builds are stored in the `build` folder.
* All builds are given the URL `http://<name>.bknix:8001`.

## Tips

* If you don't already have `git`, patch `default.nix` and add it to the list of `buildInputs`.
* If you're doing development on the initialization, use `bknix purge` to produce a clean folder (without any data or config).
* If you want to customize some of the `amp` policies, then:

```bash
## Setup a clean environment
git clone https://github.com/totten/bknix
cd bknix
nix-shell

## Initialize default configuration
bknix init

## Alter the configuration, e.g.
amp config
vi civicrm-buildkit/app/civibild.conf

## Start servies
bknix start
```
