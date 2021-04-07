#!/bin/sh -ex

sudo snap install microk8s --classic --channel=1.19
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
set +x
if [ -z "`cat /boot/firmware/cmdline.txt | grep -o 'cgroup_enable=memory'`" ]; then
  echo 'cgroup_enable=memory cgroup_memory=1' | sudo tee -a /boot/firmware/cmdline.txt
fi

echo 'Run `newgrp microk8s` to enable the necessary permisions'
