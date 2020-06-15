<?php
use Loco\Loco;

// If there is a file "/etc/bknix-ci/dynamic_env_MYUSER.sh", then evaluate it
// before launching services. This allows some configuration values to be
// computed dynamically.
//
// For example, on CI worker with a dynamic IP, you might construct the
// the HTTPD_DOMAIN dynamically.

Loco::dispatcher()->addListener('loco.service.create', function($e) {
  $currentUser = posix_getpwuid(posix_getuid());
  $f = sprintf('/etc/bknix-ci/dynamic_env_%s.sh', $currentUser['name']);
  if (file_exists($f)) {
    $e['service']->run = sprintf(". %s; exec %s", escapeshellarg($f), $e['service']->run);
  }
});
