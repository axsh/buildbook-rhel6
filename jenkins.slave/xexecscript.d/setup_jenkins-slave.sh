#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot $1 $SHELL -ex <<'EOS'
  if chkconfig --list jenkins; then
    chkconfig jenkins off
    chkconfig --list jenkins
  fi
EOS

chroot $1 su - jenkins <<'EOS'
  [ -d .ssh ] || mkdir -m 700 .ssh
  : >       /var/lib/jenkins/.ssh/authorized_keys
  chmod 644 /var/lib/jenkins/.ssh/authorized_keys
EOS
