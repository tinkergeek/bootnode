#!/bin/bash

mkdir /cluster/root_fs
cd /cluster/root_fs

mkdir etc
cp /etc/passwd /etc/group /etc/shadow etc/

dnf install -y --setopt=install_weak_deps=False --installroot=/cluster/root_fs --releasever=8 NetworkManager ansible bash-completion bc bind-utils bzip2 ca-certificates chrony dhcp-client dmidecode ethtool gcc gcc-c++ ipcalc ipmitool kernel kernel-core kernel-devel kernel-tools less lsof mailx make microcode_ctl nano nfs-utils nss_db openssh-clients openssh-server pdsh pdsh-rcmd-ssh psmisc rsync rsyslog sudo symlinks tar tcpdump tmux traceroute unzip vim wget yum yum-utils zip zsh tk tcsh tcl gcc-gfortran python36 numactl-libs hostname selinux-policy pmix kexec-tools

sed -i s/^SELINUX=.*$/SELINUX=disabled/ etc/selinux/config
