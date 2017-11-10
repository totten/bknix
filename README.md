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

This puts you in a development environment with Apache and MySQL. You can
start and stop the services using `bkctl`, eg

```
bkctl start
```
