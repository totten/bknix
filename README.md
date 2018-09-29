`bknix` is a highly opinionated environment for developing in PHP/JS -- esp for developing patches/add-ons for CiviCRM.

__Comparison with other development environments__: `bknix` serves a function similar to MAMP or XAMPP -- it facilitates local development by
bundling Apache/PHP/etc with a small launcher to run the servers.  However, it is built with the open-source [nix package
manager](https://nixos.org/nix) (compatible with OS X and Linux).  Like Docker, `nix` lets you create a small project with a manifest-file, and it
won't interfere with your normal system settings. However, unlike Docker, it is not coupled to the Linux kernel.  This significantly improves
performance on OS X workstations -- especially if the PHP/JS codebase is large.

(*To be sure, MAMP and Docker both have other advantages -- e.g. MAMP/XAMPP provide a GUI launcher/configuration screen, and Docker's ecosystem touches on process-orchestration, volume-management, virtualized networking, etc. I just don't need those things as much as I need fast/transparent filesystem and portability.*)

__Highly opinionated__:

 * It is primarily intended for developing patches and extensions for CiviCRM -- this influences the set of tools included.
 * It combines service binaries (`mysqld`, `httpd`, etc) from [nix](https://nixos.org/nix) and a toolchain from [buildkit](https://github.com/civicrm/civicrm-buildkit) and an unsophisticated process-management script (`bknix`).
 * To facilitate quick development with any IDE/editor, all file-storage and development-tasks run in the current users' local Linux/macOS (*without* any virtualization, containerization, invisible filesystems, or magic permissions).
 * To optimize DB performance, `mysqld` stores all its data in a ramdisk.
 * To avoid conflicts with other tools on your system, all binaries are stored in their own folders, and services run on their own ports.
 * There are a few different configurations. Each configuration has its own mix of packages (e.g. PHP 5.6 + MySQL 5.5; PHP 7.0 + MySQL 5.7). These are named:
   * `min`: An older set of binaries based on current system requirements.
   * `max`: A newer set of binaries based on highest that we aim to support.
   * `dfl`: An in-between set of binaries.

__This project is a work-in-progress.__ Some tasks/issues are described further down.

## Requirements

The system should meet two basic requirement:

* Run Linux or OS X on the local workstation
* Install the [nix package manager](https://nixos.org/nix/)

Additionally, you should have some basic understanding of the tools/systems involved:

* Git
* PHP/JS development (e.g. `composer`, `npm`)
* Unix CLI (e.g. `bash`)
* Process management (e.g. `ps`, `kill`), esp for `httpd` and `mysqld`
* Filesystem management (e.g. "Disk Utility" on OSX; `umount` on Linux)

## Quick Start

Let's install the PHP, MySQL, et al to `/nix/var/nix/profiles/bknix-dfl` -- and run them all on the command-line.

```bash
## Download all the binaries for the default (dfl) profile
## (It may take a while to get the binaries.)
sudo -i nix-env -i -p /nix/var/nix/profiles/bknix-dfl -f 'https://github.com/totten/bknix/archive/master.tar.gz' -E 'f: f.profiles.dfl'

## Setup the environment
## - Call the following two commands manually.
## - ALSO, add these two commands to your login script (~/.profile or ~/.bashrc)
export PATH=/nix/var/nix/profiles/bknix-dfl/bin:$PATH
eval $(bknix env --data-dir "$HOME/bknix")

## Initialize the data directory. This provides `civibuild.conf`, `httpd.conf`, `redis.conf`, etc as well as civicrm-buildkit.
## (It may take a while to download civicrm-buildkit.)
bknix init

## Start the daemons
bknix run
```

At this point, you can open a new terminal and do more interesting things, e.g.

```bash
civibuild create dmaster
```

> TIP: If the `civibuild` is missing, go back to "Setup the environment". Ensure that these commands are part of `~/.profile` or `~/.bashrc`.

## Shutdown and Startup

Eventually, you may need to shutdown or restart the services. Here's how:

* *To shutdown Apache, PHP, and Redis*: Go back to the original terminal where `bknix run` is running. Press `Ctrl-C` to stop it.
* *To shutdown MySQL*: Run `amp mysql:stop` (or `killall mysqld`). Then, use `umount` (Linux) or `Disk Utility` (OS X) to eject the ramdisk.

You can start Apache/PHP/Redis again by simply invoking the `bknix run` command again.

Restarting MySQL is a bit more tricky -- all the databases were lost when the ramdisk was destroyed. You can restore
the databases to a pristine snapshot with `civibuild restore` or `civibuild reinstall` -- like one of these:

```
civibuild restore dmaster
civibuild reinstall dmaster
```

> TIP: For other installation examples, see [doc/install-other.md](doc/install-other.md).

## Policies/Opinions

| Service     | Typical Port | (CI) dfl Port| (CI) min Port| (CI) max Port|
|-------------|--------------|--------------|--------------|--------------|
| Apache HTTP | 8001         | 8001         | 8002         | 8003         |
| Memcached   | 12221        | 12221        | 12222        | 12223        |
| MySQL       | 3307         | 3307         | 3308         | 3309         |
| PHP FPM     | 9009         | 9009         | 9010         | 9011         |
| PHP Xdebug  | 9000         | 9000         | 9000         | 9000         |
| Redis       | 6380         | 6380         | 6381         | 6382         |

* A "build" is a collection of PHP/JS/CSS/etc source-code projects, with a database and an HTTP virtual host. You can edit/commit directly in the source-tree.
* All builds are stored in the `build` folder.
* All builds are given the URL `http://<name>.bknix:8001`. (Changeable)
* All hostnames are registered in `/etc/hosts` using `sudo`. (Changeable)
* All services run as the current, logged-in user. This means that files require no special permissions.
* MySQL launches on-demand with all-ram-disk-based storage. Launching is triggered on-demand (`civibuild create ...`) or by calling `amp mysql:start`
* PHP enables `xdebug`, which connects to a debugger UI on port 9000. (Changeable)

Some of these policies/opinions can be changed, as described below ("Extended installation")

## TODO/Issues

* Sort out php-imap
* Make it easier to switch between php56, php70, php71. (Currently, you need to search/replace in `default.nix`.)
* Instead of putting most code in `./civicrm-buildkit`, put it in `$out`. (Preferrably... without neutering git cache.)
* `mysqld` is spawned in the background via `amp` (b/c that has the automated ramdisk handling). However, it'd be conceptually cleaner
  to launch `mysqld` in the foreground via `bknix run`.

## Tips

(**Stale**: These tips should be rewritten to match the new "Quick Start" approach)

* To run Civi unit tests with xdebug in PHPStorm...
    * Lookup and register the PHP interpreter.
        * In CLI, run `nix-shell` and `which php`.
        * In PHPStorm, open "Preferences" and find list of PHP interpreters. Register this one.
    * Lookup and register the PATH.
        * In CLI, run `nix-shell` and `echo $PATH`.
        * In PHPStorm, open "Run => Edit Configurations". For the default PHPUnit, add an environment variable `PATH` with the given value.
        * If there are active PHPUnit configurations, update them or delete them (so they can be regenerated on-demand).
    * In the future -- whenever you upgrade the PHP runtime -- you may need to update these settings.
* If you don't already have `git` on your system, patch `default.nix` and add it to the list of `buildInputs`.
  However, if you already have it, then leave the default. (This would prevent potential concerns about different programs managing the same `.git` folders.)
* To open a MySQL command prompt with admin credentials, run `amp sql -a`.
* If you're doing development on the bknix initialization process, use `bknix purge` to produce a clean folder (without any data or config).
* When you shutdown, the mysql ramdisk remains in memory. To remove or reset it, unmount it with `umount` (in Linux) or *Disk Utility* (in OS X).

## Updates

(**Stale**: These update steps should be rewritten to match the new "Quick Start" approach)

There are a few levels of updates. They run a spectrum from regular (daily)
to irregular (once every months).

* (*Most frequent; perhaps every day*) *Update the CiviCRM source*: See [CiviCRM Developer Guide: civibuild](https://docs.civicrm.org/dev/en/latest/tools/civibuild/#upgrade-site)
* (*Mid-level; perhaps every couple weeks*) *Update buildkit's CLI tools*: Run `bknix update`.
* (*Least frequent; perhaps every couple months*) *Update the full `bknix` stack (mysqld/httpd/etc)*: This takes a few steps.
    * If you haven't already, shutdown any active services (`Ctrl-C` in the background terminal)
    * Exit any active `nix-shell` environments.
    * In the `bknix` directory, update the git repo (i.e. `git pull`).
    * Open a new `nix-shell` and run `bknix update`
    * If you have an IDE configuration which references the PHP interpreter or PATH, update the IDE.
