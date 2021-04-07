#!/bin/sh -ex

sudo snap install microk8s --classic --channel=1.19
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
if [ -z "`cat /boot/firmware/cmdline.txt | grep -o 'cgroup_enable=memory'`" ]; then
  unset -x
  echo 'cgroup_enable=memory cgroup_memory=1' | sudo tee -a /boot/firmware/cmdline.txt
  set -x
fi
newgrp microk8s
