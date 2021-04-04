#!/bin/sh -e

sudo snap install microk8s --classic --channel=1.19
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
if [ -z "`cat /boot/firmware/cmdline.txt | grep -o 'cgroup_enable=memory'`" ]; then
  echo 'cgroup_enable=memory cgroup_memory=1' | sudo tee -a /boot/firmware/cmdline.txt
fi
echo 'Run `su - $USER` to re-enter the shell session with the updates in place'
