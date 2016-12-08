#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

declare chroot_dir=$1

chroot $1 $SHELL -ex <<'EOS'
  releasever=$(< /etc/yum/vars/releasever)
  majorver=${releasever%%.*}

  openvswitch_version=2.3.1

  repourl=http://dlc.openvnet.axsh.jp/packages/rhel/6/third_party/current/x86_64

  case "${releasever}" in
    *)
      curl -Lf -o openvswitch-kmod.rpm https://www.dropbox.com/s/m0ign1weh6axd5f/kmod-openvswitch-2.3.1-1.el6.x86_64.rpm?dl=0
      yum -y localinstall openvswitch-kmod.rpm
      curl -Lf -o openvswitch.rpm https://www.dropbox.com/s/dri05zf7diumg5o/openvswitch-2.3.1-1.x86_64.rpm?dl=0
      yum -y localinstall openvswitch.rpm
      ;;
  esac
EOS
