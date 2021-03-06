#!/bin/sh

microk8s start
for SVC in snap.microk8s.daemon-cluster-agent \
           snap.microk8s.daemon-containerd \
           snap.microk8s.daemon-apiserver \
           snap.microk8s.daemon-apiserver-kicker \
           snap.microk8s.daemon-control-plane-kicker \
           snap.microk8s.daemon-proxy \
           snap.microk8s.daemon-kubelet \
           snap.microk8s.daemon-scheduler \
           snap.microk8s.daemon-controller-manager; do

  if systemctl status ${SVC} | grep -o 'Active: failed'; then
    sudo systemctl reset-failed ${SVC}.service
    sudo systemctl start ${SVC}.service
  elif ! (systemctl status ${SVC} | grep 'Active: active'); then
    sudo systemctl restart ${SVC}.service || sudo systemctl start ${SVC}.service
    echo "Restarted ${SVC}"
  fi
done
