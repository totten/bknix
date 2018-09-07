# Using bknix in your main shell (new/untested)

## Pick a configuration

bknix supports a few different configurations (which track `civicrm.org` policy):

   * `min`: An older set of binaries based on current system requirements. (Ex: PHP 5.5 and MySQL 5.5)
   * `max`: A newer set of binaries based on highest that we aim to support. (Ex: PHP 7.1 and MySQL 5.7)
   * `dfl`: An in-between set of binaries. (Ex: PHP 5.6 and MySQL 5.7)

For the rest of this tutorial, we'll assume you want the default `dfl` configuration.  However, you can change `dfl` to `min` or` max`.

## Download and install

After installing [nix package manager](https://nixos.org/nix/), simply clone this repo:

```
me@localhost:~$ git clone https://github.com/totten/bknix
```

There are several programs that we would like to install.  The `nix-env` command allows us to add these to your default environment.

```
me@localhost:~$ cd bknix
me@localhost:~/bknix$ nix-env -f . -i -E 'f: f.profiles.dfl'
```

__Note__: If this is the first time that you run `nix-env` or `nix-shell` command, then the local computer needs to download or compile some software. This is
handled automatically. It may take a while the first time -- but, eventually, it ends at the same point.

Next, we need to enable some environment variables. You can do this manually for the current shell:

```
me@localhost:~/bknix$ eval $(bknix shell)
```

To ensure that it applies to future shells, update your `~/.profile` or `~/.bashrc`  to include a similar statement:

```
eval $(bknix shell)
```

## Service startup

Now, all the commands and environment variables are setup.  We need to start various servers (Apache, PHP-FPM, etc).
This command will run the services in the foreground and display a combined console log.

```
me@localhost:~$ cd bknix
me@localhost:~/bknix$ bknix run
...
[apache] Starting
[php-fpm] Starting
[redis] Starting
...
```

## Command line access

We'd like to have a shell where we can run developer commands like `civibuild`, `composer`, `drush`, or `civix`.  For
example, you can use one of these commands to create a dev site:

```
me@localhost:~$ civibuild create dmaster
me@localhost:~$ civibuild create wpmaster
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
me@localhost:~$ civibuild restore dmaster
me@localhost:~$ civibuild reinstall dmaster
```
