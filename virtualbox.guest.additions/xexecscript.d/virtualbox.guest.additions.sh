#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

declare chroot_dir=$1

chroot $1 $SHELL -ex <<'EOS'
  mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.saved

  cat <<-'REPO' > /etc/yum.repos.d/CentOS-Base.repo
	[base]
	name=CentOS-$releasever - Base
	baseurl=http://centos.data-hotel.net/pub/linux/centos/$releasever/os/$basearch/
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

	[updates]
	name=CentOS-$releasever - Updates
	baseurl=http://centos.data-hotel.net/pub/linux/centos/$releasever/updates/$basearch/
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
	REPO
EOS

chroot $1 $SHELL -ex <<'EOS'
  latest_ver=$(curl -fsSkL http://download.virtualbox.org/virtualbox/LATEST.TXT)

  iso_file=VBoxGuestAdditions_${latest_ver}.iso
  iso_path=/tmp/${iso_file}
  iso_uri=http://download.virtualbox.org/virtualbox/${latest_ver}/${iso_file}

  until curl -fSkL -o ${iso_path} ${iso_uri}; do
    sleep 1
  done

  mnt_path=/mnt

  mount -o loop ${iso_path} ${mnt_path}
  yum install --disablerepo=updates -y make kernel-devel gcc perl bzip2

  # https://forums.virtualbox.org/viewtopic.php?f=3&t=58855
 #yum install --disablerepo=updates -y libdrm-devel
 #drm_inc_path=$(rpm -ql kernel-devel | grep /include/drm | head -1)
 #for i in drm.h drm_sarea.h drm_mode.h drm_fourcc.h; do
 #  ln -fs /usr/include/drm/${i} ${drm_inc_path}/${i}
 #done
  # http://www.turnkeylinux.org/node/3597
  ${mnt_path}/VBoxLinuxAdditions.run --nox11 || :
  #   --nox11               Do not spawn an xterm
 #cat /var/log/vboxadd-install.log

  umount ${mnt_path}
  rm ${iso_path}
EOS

chroot $1 $SHELL -ex <<'EOS'
  mv /etc/yum.repos.d/CentOS-Base.repo.saved /etc/yum.repos.d/CentOS-Base.repo
EOS
