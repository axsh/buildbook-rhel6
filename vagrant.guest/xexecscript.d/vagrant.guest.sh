#!/bin/bash
#
# requires:
#  bash
#
set -e

declare chroot_dir=$1

chroot $1 $SHELL -ex <<'EOS'
  user_name=vagrant
  user_group=${user_name}
  user_home=/home/${user_name}

  groupadd    ${user_group} 
  useradd  -g ${user_group} -d ${user_home} -s /bin/bash -m ${user_name}

  egrep -q ^umask ${user_home}/.bashrc || {
    echo umask 022 >> ${user_home}/.bashrc
  }

  user_ssh_dir=${user_home}/.ssh
  authorized_keys_path=${user_ssh_dir}/authorized_keys

  [[ -d "${user_ssh_dir}" ]] || mkdir -m 0700 ${user_ssh_dir}
  # make sure to directory attribute is 0700
  chmod 0700 ${user_ssh_dir}

  until curl -fsSkL https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub >> ${authorized_keys_path}; do
    sleep 1
  done

  echo         root:${user_name} | chpasswd
  echo ${user_name}:${user_name} | chpasswd

  chown -R ${user_group}:${user_name} ${user_ssh_dir}
EOS
