#!/bin/sh

NODE_USER="${1}"
NODE_PRIVATE_IP="${2}"
SSH_KEY_PATH="${HOME}/microponics/keys/microponics"

if [ -z "${NODE_USER}" ] || [ -z "${NODE_PRIVATE_IP}" ]; then
  echo "Error: incorrect usage"
  echo "Correct usage: ~/microponics/add-node.sh <NODE_USER> <NODE_PRIVATE_IP>" 
  exit 1
fi

eval `ssh-agent`
chmod 600 ${SSH_KEY_PATH}
ssh-add ${SSH_KEY_PATH}
ssh -o "StrictHostKeyChecking no" ${NODE_USER}@${NODE_PRIVATE_IP} "echo 'expirement98' | sudo -S /snap/bin/microk8s join $(ip route get 1.2.3.4 | awk '{print $7}' | head -n 1):25000/$(microk8s add-node | grep 'microk8s join' | head -n 1 | grep -Eo '[a-z0-9]{32}$')"
eval `ssh-agent -k`
