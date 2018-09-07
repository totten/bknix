# Using bknix in a subshell

## Download

After installing [nix package manager](https://nixos.org/nix/), simply clone this repo:

```
git clone https://github.com/totten/bknix
```

## Pick a configuration

bknix supports a few different configurations (which track `civicrm.org` policy):

   * `min`: An older set of binaries based on current system requirements. (Ex: PHP 5.5 and MySQL 5.5)
   * `max`: A newer set of binaries based on highest that we aim to support. (Ex: PHP 7.1 and MySQL 5.7)
   * `dfl`: An in-between set of binaries. (Ex: PHP 5.6 and MySQL 5.7)

For the rest of this tutorial, we'll assume you want the default `dfl` configuration.  However, you can change `dfl` to `min` or` max`.

## Service startup

We need to start various servers (Apache, PHP-FPM, etc). This command will run the services in the foreground and display a combined console log.

```
me@localhost:~$ cd bknix
me@localhost:~/bknix$ nix-shell -A dfl --command 'bknix run'
...
[apache] Starting
[php-fpm] Starting
[redis] Starting
...
```

__Note__: If this is the first time that you run `nix-shell` command, then the local computer needs to download or compile some software. This is
handled automatically. It may take a while the first time -- but, eventually, it ends at the same point.

## Command line access

We'd like to have a shell where we can run developer commands like `civibuild`, `composer`, `drush`, or `civix`.  Open a new terminal and run `nix-shell` without any arguments:

```
me@localhost:~$ cd bknix
me@localhost:~/bknix$ nix-shell -A dfl
[nix-shell:~/bknix]$
```

Within the `nix-shell`, you have access to all commands.  For example, you can use one of these commands to create a dev site:

```
[nix-shell:~/bknix]$ civibuild create dmaster
[nix-shell:~/bknix]$ civibuild create wpmaster
```

In the dev site, you can browse the site, edit code, etc.

## Shutdown and restart services

Eventually, you may need to shutdown or restart the services. Here's how:

* *To shutdown Apache, PHP, and Redis*: Go back to the original terminal where `bknix run` is running. Press `Ctrl-C` to stop it.
* *To shutdown MySQL*: Run `killall mysqld`. Then, use `umount` (Linux) or `Disk Utility` (OS X) to eject the ramdisk.

You can start Apache/PHP/Redis again by simply invoking the `bknix run` command again.

Restarting MySQL is a bit more tricky -- all the databases were lost when the ramdisk was destroyed. You can restore
the databases to a pristine snapshot with `civibuild restore` or `civibuild reinstall` -- either:

```
[nix-shell:~/bknix]$ civibuild restore dmaster
[nix-shell:~/bknix]$ civibuild reinstall dmaster
```
