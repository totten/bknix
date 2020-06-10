# nix-shell: Run bknix in a temporary subshell

(*This assumes that you have already [met the basic requirements](requirements.md).*)

In this tutorial, we'll start a new subshell with all of the packages for `dfl`.  The packages will only be visible within our
shell.

This approach minimizes the impact on other parts of the subsystem.  It is easier to juggle multiple profiles (and to
change the profile definition) if you work within a subshell.

## Quick Version

This document can be summarized as a few small commands:

```
me@localhost:~$ git clone https://github.com/totten/bknix
me@localhost:~$ nix-env -iA cachix -f https://cachix.org/api/v1/install
me@localhost:~$ cachix use bknix
me@localhost:~$ cd bknix
me@localhost:~/bknix$ nix-shell -A dfl
[nix-shell:~/bknix]$
```

The rest of this document explains these steps in more depth. If you already
understand them, then proceed to [bknix: General usage (loco)](usage-loco.md) or [bknix: General usage (legacy)](usage-legacy.md).

## Step 1. Download bknix definitions

The `bknix` repository stores some *metadata* -- basically, a list of required packages.  We download a copy via `git`:

```
git clone https://github.com/totten/bknix
```

This should be pretty quick.

## Step 2. (Optional) Warmup with prebuilt binaries

`nix` does the heavy lifting of downloading packages. It can download prebuilt binaries; and it can build new binaries
(from source); and all of this is automated and generally works without any special steps.

There's a small catch.  Installing prebuilt binaries is faster than building from source.  The official download server
(`cache.nixos.org`) only has binaries for official packages -- but not for our customized packages.  To get prebuilt
binaries for our customized packages, you can use the supplemental "cachix" system.  This command downloads binaries
wherever they're available (official or supplemental servers).

```
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use bknix
```

## Step 3. (Day-to-day) Open a subshell

Whenever you want to work with `bknix`, navigate into its folder and run `nix-shell -A dfl`.

```
cd bknix
nix-shell -A dfl
```

Notice that the option `-A dfl` specifies the profile to use.

There's one other thing notice, but we'll need a more complete copy of the shell output to see it:

```
me@localhost:~$ cd bknix
me@localhost:~/bknix$ nix-shell -A dfl
[nix-shell:~/bknix]$
```

After running `nix-shell`, the command-prompt changes. This demonstrates that we're working in the new shell with a properly configured environment.

Once we know how to open a shell, we can proceed to [bknix: General usage (loco)](usage-loco.md) or [bknix: General usage (legacy)](usage-legacy.md).
