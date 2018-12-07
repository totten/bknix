`bknix` is a highly opinionated environment for developing in PHP/JS -- esp for developing patches/add-ons for CiviCRM.

__Comparison with other development environments__: `bknix` serves a function similar to MAMP or XAMPP -- it facilitates local development by
bundling Apache/PHP/etc with a small launcher to run the servers.  However, it is built with the open-source [nix package
manager](https://nixos.org/nix) (compatible with OS X and Linux).  Like Docker, `nix` lets you create a small project with a manifest-file, and it
won't interfere with your normal system settings. However, unlike Docker, it is not coupled to the Linux kernel.  This significantly improves
performance on OS X workstations -- especially if the PHP/JS codebase is large.

(*To be sure, MAMP and Docker both have other advantages -- e.g. MAMP/XAMPP provide a GUI launcher/configuration screen, and Docker's ecosystem touches on process-orchestration, volume-management, virtualized networking, etc. I just don't need those things as much as I need fast/transparent filesystem and portability.*)

__Highly opinionated__:

* It is primarily intended for developing patches and extensions for CiviCRM -- this influences the set of tools included.
* It combines service binaries (`mysqld`, `httpd`, etc) from [nix](https://nixos.org/nix) with an unsophisticated process-manager script (`bknix`) and all the tools from [buildkit](https://github.com/civicrm/civicrm-buildkit).
* To facilitate quick development with any IDE/editor, all file-storage and development-tasks run in the current users' local Linux/macOS (*without* any virtualization, containerization, invisible filesystems, or magic permissions).
* To optimize DB performance, `mysqld` stores all its data in a ramdisk.
* To avoid conflicts with other tools on your system, all binaries are stored in their own folders, and services run on alternative ports.

__Profiles__: A *profile* is list of packages (e.g. PHP 5.6 + MySQL 5.5; PHP 7.0 + MySQL 5.7).
`bknix` includes a few profiles designed around the CiviCRM system-requirements:

* `dfl`: An in-between set of packages. This is a good default for middle-of-the-road testing/development.
* `min`: An older set of packages based on minimum system requirements.
* `max`: A newer set of packages based on maximum system requirements.
* `edge`: A newer set of packages that exceeds our current official support; a proposal for the next `max`.

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

## Usage

For day-to-day usage, you start by choosing a profile (such as `dfl`).
Open a suitable shell environment and start the process-manager (`bknix
run`). For example:

```
me@localhost:~/bknix$ nix-shell -A dfl
[nix-shell:~/bknix]$ bknix run
(bknix) Found existing php config (/Users/me/bknix/var/php). Files not changed.
(bknix) Found existing redis config (/Users/me/bknix/var/redis). Files not changed.
(bknix) Found existing memcached config (/Users/me/bknix/var/memcached). Files not changed.
(bknix) Found existing php-fpm config (/Users/me/bknix/var/php-fpm). Files not changed.
(bknix) Found existing httpd config (/Users/me/bknix/var/httpd). Files not changed.
(bknix) Found existing buildkit toolchain (/Users/me/bknix/civicrm-buildkit).
(bknix) Found existing amp config (/Users/me/bknix/var/amp). Files not changed.
(bknix) Found existing civibuild config (/Users/me/bknix/civicrm-buildkit/app/civibuild.conf). Files not changed.
[apache] Starting
[php-fpm] Starting
[redis] Starting
[memcached] Starting
```

The services are running in the foreground -- additional errors and log messages will be displayed here. 

Next, open another shell environment.  In here, you can do more development tasks -- such as building a new test site:

```
me@localhost:~/bknix$ nix-shell -A dfl
[nix-shell:~/bknix]$ civibuild create dmaster --civi-ver 5.8
```

These are the examples I use most often on my laptop -- but `nix` is quite versatile about how you setup profiles and
shell environments. For a more complete tutorial, it will help to choose an approach based on how you'll be using it.
For example:


| Goal | Suggestion |
| ---- | ---- |
| Try bknix to see what it does | <ul><li>[nix-shell: Run bknix in a temporary subshell](doc/nix-shell.md)</li><li>[bknix: General usage](doc/usage.md)</li></ul> |
| Develop extensions or patches for Civi in a CLI environment | <ul><li>[nix-shell: Run bknix in a temporary subshell](doc/nix-shell.md)</li><li>[bknix: General usage](doc/usage.md)</li></ul> |
| Develop extensions or patches for Civi in an IDE | <ul><li>[nix-env: Install bknix to a profile folder](doc/install-profile.md)</li><li>[bknix: General usage](doc/usage.md)</li></ul> |
| Develop patches for bknix| <ul><li>[nix-shell: Run bknix in a temporary subshell](doc/nix-shell.md)</li><li>[bknix: General usage](doc/usage.md)</li></ul> |
| Run frequent tests in a mix of environments (continuous-integration) | <ul><li>[install-ci.sh: Install all profiles and system services](doc/install-ci.md)</li></ul> |

## Policies/Opinions

| Service     | Typical Port |
|-------------|--------------|
| Apache HTTP | 8001         |
| Memcached   | 12221        |
| MySQL       | 3307         |
| PHP FPM     | 9009         |
| PHP Xdebug  | 9000         |
| Redis       | 6380         |

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
