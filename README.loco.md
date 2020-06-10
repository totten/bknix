`bknix` is a highly opinionated environment for developing in PHP/JS -- esp for developing patches/add-ons for CiviCRM.

## Background

* [Critical comparison](doc/comparison.md)
* [Requirements](doc/requirements.md)

## Profiles

A *profile* is list of packages (e.g. PHP 7.0 + MySQL 5.7 + Redis 4.0 + NodeJS 6.14).  `bknix` includes a few profiles designed around the
CiviCRM system-requirements:

* [dfl](profiles/dfl/default.nix): An in-between set of packages. This is a good default for middle-of-the-road testing/development.
* [min](profiles/min/default.nix): An older set of packages based on minimum system requirements.
* [max](profiles/max/default.nix): A newer set of packages based on maximum system requirements.
* [edge](profiles/edge/default.nix): A newer set of packages that exceeds our current official support; a proposal for the next `max`.

## Usage

For day-to-day usage, you start by choosing a profile (such as `dfl`).  Open a suitable shell environment and start the process-manager
(`loco run`).  For example:

```
me@localhost:~$ cd bknix
me@localhost:~/bknix$ use-bknix min -s
[nix-shell:~/bknix]$ loco run
...
======================[ Startup Summary ]======================
[VOLUME] Loco data volume is a ram disk "/Users/myuser/bknix/.loco/var".
[redis] Redis is running on "127.0.0.1:6380".
[php-fpm] PHP-FPM is running on "127.0.0.1:9009"
[mailcatcher] Mailcatcher is running on "smtp://127.0.0.1:1025" and "http://127.0.0.1:1080"
[apache-vdr] Apache HTTPD is running at "http://127.0.0.1:8001" with content from "/Users/myuser/bknix/build".
[mysql] MySQL is running on "127.0.0.1:3307". The default credentials are user="root" and password="".
[buildkit] Buildkit (/Users/myuser/bknix/civicrm-buildkit) is configured to use these services. It produces builds in "/Users/myuser/bknix/build".

Services have been started. To shutdown, press Ctrl-C.
===============================================================
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

<table border="0">
  <thead>
    <tr>
      <th>Goal</th>
      <th>Suggestion</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <ul>
          <li>Try bknix to see what it does</li>
          <li>Develop extensions or patches for Civi in a CLI environment</li>
          <li>Develop patches for <code>bknix.git</code></li>
        </ul>
      </td>
      <td>
        <ul>
          <li><a href="doc/nix-shell.md">nix-shell: Run bknix in a temporary subshell</a></li>
          <li><a href="doc/usage-loco.md">bknix: General usage</a></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>
        <ul>
          <li>Develop extensions or patches for Civi in an IDE</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><a href="doc/install-developer.md">install-developer.sh: Install all profiles for use by a single developer</a></li>
          <li><a href="doc/usage-loco.md">bknix: General usage</a></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>
        <ul>
          <li>Run frequent tests in a mix of environments (continuous-integration)</li>
        </ul>
      </td>
      <td>
        <ul>
          <li><a href="doc/install-ci.md">install-ci.sh: Install all profiles and system services for concurrent usage</a></li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

## Ports

With `nix-shell` or `install-developer.sh`, it is typical to only launch one
"stack" of services. The services run on the following ports:

| Service     | Typical Port |
|-------------|--------------|
| Apache HTTP | 8001         |
| Memcached   | 12221        |
| MySQL       | 3307         |
| PHP FPM     | 9009         |
| PHP Xdebug  | 9000         |
| Redis       | 6380         |
| Mailcatcher (SMTP) | 1025  |
| Mailcatcher (HTTP) | 1080  |

With `install-ci.sh`, the services use a wide range of ports.

<!-- FIXME: Document use of HTTPD_PORT, MYSQLD_PORT, etc -->

<!--

FIXME: rewrite this for master-loco branch

* A "build" is a collection of PHP/JS/CSS/etc source-code projects, with a database and an HTTP virtual host. You can edit/commit directly in the source-tree.
* All builds are stored in the `build` folder.
* All builds are given the URL `http://<name>.bknix:8001`. (Changeable)
* All hostnames are registered in `/etc/hosts` using `sudo`. (Changeable)
* All services run as the current, logged-in user. This means that files require no special permissions.
* MySQL launches on-demand with all-ram-disk-based storage. Launching is triggered on-demand (`civibuild create ...`) or by calling `amp mysql:start`
* PHP enables `xdebug`, which connects to a debugger UI on port 9000. (Changeable)

-->

Some of these policies/opinions can be changed, as described below ("Extended installation")

## TODO/Issues

* Sort out php-imap
* Make it easier to switch between php56, php70, php71. (Currently, you need to search/replace in `default.nix`.)
* Instead of putting most code in `./civicrm-buildkit`, put it in `$out`. (Preferrably... without neutering git cache.)
* `mysqld` is spawned in the background via `amp` (b/c that has the automated ramdisk handling). However, it'd be conceptually cleaner
  to launch `mysqld` in the foreground via `loco run`.

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
* If you're doing development on the bknix service configuration, use `loco clean` or `loco run -f` to produce a clean folder (without any data or config).
* When you shutdown, the mysql ramdisk remains in memory. To remove or reset it, unmount it with `umount` (in Linux) or *Disk Utility* (in OS X).

## Updates

(**Stale**: These update steps should be rewritten to match the new "Quick Start" approach)

There are a few levels of updates. They run a spectrum from regular (daily)
to irregular (once every months).

* (*Most frequent; perhaps every day*) *Update the CiviCRM source*: See [CiviCRM Developer Guide: civibuild](https://docs.civicrm.org/dev/en/latest/tools/civibuild/#upgrade-site)
* (*Mid-level; perhaps every couple weeks*) *Update buildkit's CLI tools*: Run `cd civicrm-buildkit && git pull && civi-download-tools`.
* (*Least frequent; perhaps every couple months*) *Update the full `bknix` stack (mysqld/httpd/etc)*: This takes a few steps.
    * If you haven't already, shutdown any active services (`Ctrl-C` in the background terminal)
    * Exit any active `nix-shell` environments.
    * In the `bknix` directory, update the git repo (i.e. `git pull`).
    * Open a new `nix-shell` and run `bknix update`
    * If you have an IDE configuration which references the PHP interpreter or PATH, update the IDE.
