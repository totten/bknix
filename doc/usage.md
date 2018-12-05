# bknix: General usage

Once you know how to setup a shell (with [nix-shell](nix-shell.md) or [nix-env -i](install-profile.md)), we can start using `bknix`.

## Quick Version

The highlights of this document can be summarized as a few steps:

```
# Step 1. Initialize the data directory (Optional)
bknix init

# Step 2. Run the services
bknix run

# Step 3. Do developer-y stuff (New shell)
civibuild create dmaster
```

The rest of this document explains these steps in more depth. 

## Step 1. Initialize the data directory (Optional)

The data directory (`$BKNIXDIR`) stores several things:

* `var` - Auto-generated configuration files (like civibuild.conf`, `httpd.conf`, or `redis.conf`), PID files, log files, etc
* `civicrm-buildkit` - A collection of PHP/JS tools like `civix`, `phpunit4`, or `drush`
* `build` - A workspace with various git repos for developing code

The `bknix init` command initializes this folder.

This step is optional -- if you skip it, then it will be done automatically.  However, doing this yourself provides
a good opportunity to customize the configuration.

The first way to customize is to pass options into `bknix init`, as in:

```
$ env HTTPD_PORT=8001 \
  MEMCACHED_PORT=12221 \
  PHPFPM_PORT=9009 \
  REDIS_PORT=6380 \
  bknix init
(bknix) Initialize php config (/Users/me/bknix/var/php)
(bknix) Initialize redis config (/Users/me/bknix/var/redis)
(bknix) Initialize memcached config (/Users/me/bknix/var/memcached)
(bknix) Initialize php-fpm config (/Users/me/bknix/var/php-fpm)
(bknix) Initialize httpd config (/Users/me/bknix/var/httpd)
(bknix) Initialize buildkit toolchain (/Users/me/bknix/civicrm-buildkit)
(bknix) Initialize amp config (/Users/me/bknix/var/amp)
(bknix) Initialize civibuild config (/Users/me/bknix/civicrm-buildkit/app/civibuild.conf)
```

For full details on command usage, run `bknix init -h`

After the data directory are generated, you can edit the configuration files to taste -- with commands like:

```
vi var/php-fpm/php-fpm.conf
less civicrm-buildkit/app/civibuild.conf.tmpl
vi civicrm-buildkit/app/civibuild.conf
# ... and so on ...
```

Some interesting configurations:

* Setup default passwords for the admin and demo users.
    * Edit `civicrm-buildkit/app/civibuild.conf`
    * Set `ADMIN_PASS` and `DEMO_PASS`.
    * These will affect future builds.
* Setup wildcard DNS. (With wildcard DNS, your builds don't need to be registered in `/etc/hosts`, so this avoids `sudo` usage.)
    * Search Google for instructions for installing `dnsmasq` on your platform (e.g. `dnsmasq ubuntu` or `dnsmasq osx`).
    * Run `amp config:set --hosts_type=none`. (This tells `amp` that it doesn't need to do any special work setup DNS records.)
<!-- * Set the PHP timezone in `config/php.ini`. -->
<!-- * Create `etc/bashrc.local` with some CLI customizations -->

(*Aside*: You can update these settings after initial setup, but some settings may require destroying/rebuilding.)

# Step 2. Run the services

Once the data folder is initialized, you can start the major services (`httpd`, `php-fpm`, etc).

```
$ bknix run
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

If you need to stop these services, simply press `Ctrl-C`.

# Step 3. Do developer-y stuff

Once the services are running, you can open a new terminal and do more interesting things, e.g.

```
civibuild create -h
```

or

```
civibuild create dmaster
```

> TIP: If the `civibuild` is missing, then the environment has probably not been setup correctly. Go back to the guidelines for
> [nix-shell](nix-shell.md) or [nix-env -i](install-profile.md).

For more documentation on `civibuild`, see [Developer Guide: Tools: civibuild](https://docs.civicrm.org/dev/en/latest/tools/civibuild/).

## MySQL Shutdowns and Reboots

Eventually, you may need to shutdown or restart the services. This works intuitively for most services; as mentioned above,
most services will be stopped by simply pressing `Ctrl-C` in the console. But MySQL is special.

To fully and manually shutdown MySQL:

* *Stop MySQL daemon*: Run `amp mysql:stop`. (If this doesn't work for some reason, use `killall mysqld` or `killall -9 mysqld`). 
* *Stop MySQL ramdisk*:
    * (Linux): Run `mount` to display a list of filesystems. Note the path to the "amp" ramdisk. Use `umount` to unmount it.
    * (OS X): Open the "Disk Utility" and eject the "AMP" ram disk.

Shutting down or restarting the workstation will also stop MySQL.

How do you bring MySQL back online? If I'm working on a build named `dmaster`, then I'd run one of these two commands:

```
### Load a saved DB snapshot of dmaster. If mysql isn't running, it autostarts.
civibuild restore dmaster

### Build a new DB and new settings files for dmaster.  If mysql isn't running, it autostarts.
civibuild reinstall dmaster
```
