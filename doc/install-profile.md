# nix-env: Install bknix to a profile folder

(*This assumes that you have already [met the basic requirements](requirements.md).*)

Let's use the `dfl` profile and install all its packages (PHP, MySQL, etc) to one folder (`/nix/var/nix/profiles/bknix-dfl`).

If you need to integrate with tools, workflows, or initialization systems that are not specifically aware of `nix` (such as a graphical IDE
or system-level process manager), this may be the most convenient arrangement. It feels a bit like installing an application suite under
`/opt/<foo>` except that the actual path is `/nix/var/nix/profiles/<foo>`.

## Quick Version

This document can be summarized as two steps (three commands):

```
me@localhost:~$ sudo -i nix-env -i \
  -f 'https://github.com/totten/bknix/archive/master.tar.gz' -E 'f: f.profiles.dfl' \
  -p /nix/var/nix/profiles/bknix-dfl \
  --option binary-caches "https://bknix.think.hm/ https://cache.nixos.org" --option require-sigs false
me@localhost:~$ export PATH=/nix/var/nix/profiles/bknix-dfl/bin:$PATH
me@localhost:~$ eval $(bknix env --data-dir "$HOME/bknix")
```

The rest of this document explains these steps in more depth.  If you
already understand them, then proceed to [bknix: General usage](usage.md).

## Download

The command `nix-env -i` will download all of the packages for `dfl`.

```bash
sudo -i nix-env -i \
  -f 'https://github.com/totten/bknix/archive/master.tar.gz' -E 'f: f.profiles.dfl' \
  -p /nix/var/nix/profiles/bknix-dfl \
  --option binary-caches "https://bknix.think.hm/ https://cache.nixos.org" --option require-sigs false
```

Let's break down into a few parts:

* `sudo -i` means *run the command as `root`*
* `nix-env -i` means *install packages to a live environment*
* `-f 'https://github.com/totten/bknix/archive/master.tar.gz'` means *download the latest bknix configuration file from Github*
* `-E 'f: f.profiles.dfl'` means *evaluate the configuration file and return property `f.profiles.dfl` (the list of packages for `dfl`))*
* `-p /nix/var/nix/profiles/bknix-dfl` means *put the packages in the shared profile folder `bknix-dfl`*
* `--option binary-caches ...` means *download pre-compiled packages from the official `cache.nixos.org` server and the supplemental `bknix.think.hm` server*

The command may take some time when you first it -- it will need to download a combination of pre-compiled binaries and source-code. (It goes
faster when using pre-compiled binaries; if those aren't available, then it will download source-code and compile it.)

Once it's finished downloading, `nix-env` creates a `bin` folder with symlinks to all of the downloaded software.

```
$ ls /nix/var/nix/profiles/bknix-dfl/bin/
ab@            bzmore@                      git-receive-pack@    memcached@                   mysql_plugin@               mysqlimport@         redis-check-aof@     zip@
apachectl@     checkgid@                    git-shell@           my_print_defaults@           mysql_secure_installation@  mysqlpump@           redis-check-rdb@     zipcloak@
bknix@         curl@                        git-upload-archive@  myisam_ftdump@               mysql_ssl_rsa_setup@        mysqlshow@           redis-cli@           zipgrep@
bunzip2@       dbmmanage@                   git-upload-pack@     myisamchk@                   mysql_tzinfo_to_sql@        mysqlslap@           redis-sentinel@      zipinfo@
bzcat@         envvars@                     htcacheclean@        myisamlog@                   mysql_upgrade@              mysqltest@           redis-server@        zipnote@
bzcmp@         envvars-std@                 htdbm@               myisampack@                  mysqladmin@                 mysqltest_embedded@  replace@             zipsplit@
bzdiff@        fcgistarter@                 htdigest@            mysql@                       mysqlbinlog@                mysqlxtest@          resolve_stack_dump@  zlib_decompress@
bzegrep@       funzip@                      htpasswd@            mysql_client_test@           mysqlcheck@                 node@                resolveip@
bzfgrep@       git@                         httpd@               mysql_client_test_embedded@  mysqld@                     npm@                 rotatelogs@
bzgrep@        git-credential-netrc@        httxt2dbm@           mysql_config@                mysqld_multi@               perror@              rsync@
bzip2@         git-credential-osxkeychain@  innochecksum@        mysql_config_editor@         mysqld_safe@                php@                 tar@
bzip2recover@  git-cvsserver@               logresolve@          mysql_embedded@              mysqldump@                  php-fpm@             unzip@
bzless@        git-http-backend@            lz4_decompress@      mysql_install_db@            mysqldumpslow@              redis-benchmark@     unzipsfx@
```

## Environment

After downloading, the programs are available in `/nix/var/nix/profiles/bknix-dfl` but their not ready to use on the command line.  You
need to setup the environment.

```
export PATH=/nix/var/nix/profiles/bknix-dfl/bin:$PATH
```

This ensures that downloaded *commands* are available. Additionally, you need to set some environment
variables to ensure that each command *stores data in the appropriate folder*.

```
eval $(bknix env --data-dir "$HOME/bknix")
```

You can run these two statements manually and they will apply to the current shell.

Additionally, to ensure that the environment is configured in the future (when you open new shells or logout/login/reboot), add
both statements to your shell initialization script (`~/.profile` or `~/.bashrc`).

Once we know how to open a shell with a well-configured environment, we can proceed to [bknix: General usage](usage.md).

## TIP: IDEs and Environments

If you use a graphical IDE, you should be able to view and edit code without any special work.  However, if you want to
use the Nice Stuff (such as debugging), then the IDE needs to have the same environment configuration.  The details
will depend a lot on your how the IDE and OS's graphical-shell work. Here are a few approaches to consider:

* In some platforms, the OS's graphical-shell might respect `~/.profile` -- which is great because everything else will pick up on this.
* In some platforms, the OS's graphical-shell might have a similar-but-different file (like `.xsession` or `.xinitrc`?).
* In some platforms, the OS's graphical-shell might let you use a custom launch command -- have it setup the environment and then run the IDE.
* In some platforms, the OS's graphical-shell might give explicit options for managing the environment of each program. Use this to add `PATH` (and all the other variables from `bknix env`).
* In some platforms, the IDE might have its own settings for manipulating the environment and registering tools and paths.
