#!/bin/bash
#
# requires:
#  bash
#
set -e

chroot $1 $SHELL -ex <<'EOS'
  yum install --disablerepo=updates -y ucarp
EOS
