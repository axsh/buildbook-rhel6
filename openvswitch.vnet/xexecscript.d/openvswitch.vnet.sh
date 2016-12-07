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

  openvswitch_version=2.3.1-1

  repourl=http://dlc.openvnet.axsh.jp/packages/rhel/6/third_party/current/x86_64

  case "${releasever}" in
    *)
      curl -Lf -o openvswitch-kmod.rpm ${repourl}/kmod-openvswitch-${openvswitch_version}.el6.x86_64.rpm
      yum -y localinstall openvswitch-kmod.rpm
      curl -Lf -o openvswitch.rpm ${repourl}/openvswitch-${openvswitch_version}.x86_64.rpm
      yum -y localinstall openvswitch.rpm
      ;;
  esac
EOS
