#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

declare chroot_dir=$1

chroot $1 $SHELL -ex <<'EOS'
  releasever=$(< /etc/yum/vars/releasever)
  majorver=${releasever%%.*}

  openvswitch_version=2.3.1

  repourl=http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/${releasever}

  case "${releasever}" in
    *)
      curl -L -o openvswitch-kmod.rpm https://www.dropbox.com/s/zvnl9kpdmnbb2a5/kmod-openvswitch-2.3.1-1.el6.x86_64.rpm?dl=0
      yum -y localinstall openvswitch-kmod.rpm
      curl -L -o openvswitch.rpm https://www.dropbox.com/s/j8mvg3zcv5mgpz0/openvswitch-2.3.1-1.x86_64.rpm?dl=0
      yum -y localinstall openvswitch.rpm
      ;;
  esac

  yum install --disablerepo=updates -y ${repourl}/openvswitch-${openvswitch_version}-1.x86_64.rpm
EOS
