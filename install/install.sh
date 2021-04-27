#!/bin/sh -ex

sudo systemctl start snapd.service
sudo apt-get install -y docker.io
sudo snap install microk8s --classic --channel=1.20
sudo usermod -a -G microk8s ${USER}
sudo chown -f -R ${USER} ${HOME}/kube
set +x

if ! (uname -a | grep -o aarch64); then
  if ! (cat /boot/firmware/cmdline.txt | grep -o 'cgroup_enable=memory'); then
    echo 'cgroup_enable=memory cgroup_memory=1' | sudo tee -a /boot/firmware/cmdline.txt
  fi
fi

set +e
if ! grep -o 'source ${HOME}/microponics/useful-aliases' ${HOME}/.bashrc; then
  printf '\nsource ${HOME}/microponics/useful-aliases\n' >> ${HOME}/.bashrc
fi
if ! grep -o '${HOME}/microponics/reinforce.sh' ${HOME}/.bashrc; then
  printf '${HOME}/microponics/reinforce.sh\n' >> ${HOME}/.bashrc
fi

echo 'Run `newgrp microk8s` to enable the necessary permisions'
