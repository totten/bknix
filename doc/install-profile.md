# nix-env: Install bknix to a profile folder

(*This assumes that you have already [met the basic requirements](requirements.md).*)

Let's use the `dfl` profile and install all its packages (PHP, MySQL, etc) to one folder (`/nix/var/nix/profiles/bknix-dfl`).

If you need to integrate with tools, workflows, or initialization systems that are not specifically aware of `nix` (such as a graphical IDE
or system-level process manager), this may be the most convenient arrangement. It feels a bit like installing an application suite under
`/opt/<foo>` except that the actual path is `/nix/var/nix/profiles/<foo>`.

## Quick Version

This document can be summarized as two steps (three commands):

<!-- TODO: Combine these into a script "install-workstation.sh"? Maybe also download nix (if it's missing /nix)? -->

```
me@localhost:~$ nix-env -iA cachix -f https://cachix.org/api/v1/install
me@localhost:~$ cachix use bknix
me@localhost:~$ git clone https://github.com/totten/bknix -b master-loco ~/bknix
me@localhost:~$ env PROFILES="dfl" DEFN=$PWD FORUSER=1 ./bin/install-profiles.sh
me@localhost:~$ sudo ln -s ~/bknix/bin/use-bknix /usr/local/bin/use-bknix
me@localhost:~$ eval $( use-bknix dfl )
```

The rest of this document explains these steps in more depth.  If you
already understand them, then proceed to [bknix: General usage](usage.md).

## Cache Setup

This step is technically optional, but it will improve download times --
allowing you to download build-compiled binaries.

```bash
sudo -i
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use bknix
```

## Download

For the download process, we perform three installation steps. First, we get
a copy of `bknix` specifications:

```bash
git clone https://github.com/totten/bknix -b master-loco ~/bknix
```

Then, we download and install the default profile (`dfl`) in `/nix/var/nix/profiles/per-user/$USER/bknix-dfl`.

```
env PROFILES="dfl" DEFN=$PWD FORUSER=1 ./bin/install-profiles.sh
```

Note the options:

* `PROFILES`: A space-delimited list profiles to install or update (within quote marks)
* `DEFN`: The location of the `bknix` specification
* `FORUSER`: The profile should be installed as a `per-user` profile

Finally, we need to register a small utility (`use-bknix`) which will help us work with bknix later.

```
sudo ln -s ~/bknix/bin/use-bknix /usr/local/bin/use-bknix
```

Once it's finished downloading, `nix-env` creates a `bin` folder with symlinks to all of the downloaded software.

```
$ ls /nix/var/nix/profiles/per-user/$USER/bknix-dfl/bin/
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

After downloading, the programs are available in `/nix/var/nix/profiles/per-user/$USER/bknix-dfl`, but they're not ready to use on the command line.

You need to setup the environment. The helper script `use-bknix` will do this, ie

```
eval $(use-bknix dfl)
```

In the example below, observe how we get access to a new version of `php`:

```
me@localhost:~/bknix$ which php
/usr/bin/php
me@localhost:~/bknix$ eval $(use-bknix dfl)
[bknix-dfl:~/bknix] which php
/nix/var/nix/profiles/bknix-dfl/bin/php
```

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
