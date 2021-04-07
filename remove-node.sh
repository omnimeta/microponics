#!/bin/sh -e

NODE="${1}"
NODE_USER_PW="expirement98" # not confidential
SSH_KEY_PATH="${HOME}/microponics/keys/microponics"

if [ -z "${NODE}" ]; then
  echo "Error: incorrect usage"
  echo "Correct usage: ~/microponics/remove-node.sh <NODE_NAME_OR_PRIVATE_IP>
  exit 1
fi

NODE_PRIVATE_IP=`echo ${NODE} | grep -Eo '^([0-9]{1,3}\.){3}[0-9]$'` 
if [ ! -z "${NODE_PRIVATE_IP} ]; then
  if [ -z "`microk8s kubectl get nodes -o wide | grep ${NODE_PRIVATE_IP}`" ]; then
    echo "Error: there is no node with private IP '${NODE}'"
    exit 1
  fi
else
  if [ -z "`microk8s kubectl get nodes -o wide | grep ${NODE}`" ]; then
    echo "Error: there is no node named '${NODE}'"
    exit 1
  fi
  NODE_PRIVATE_IP=`microk8s kubectl get nodes -o wide | grep ${NODE} | head -n 1 | grep -Eo '^([0-9]{1,3}\.){3}[0-9]$'`
fi

eval `ssh-agent`
chmod 600 ${SSH_KEY_PATH}
ssh-add ${SSH_KEY_PATH}
ssh -o "StrictHostKeyChecking no" ${NODE_PRIVATE_USER}@${NODE_PRIVATE_IP} "echo ${NODE_USER_PW} | sudo -S /snap/bin/microk8s leave"
sleep 10s
microk8s remove-node ${NODE_PRIVATE_IP}
echo "Completing removal..."
sleep 20s
eval `ssh-agent -k`
microk8s kubectl get nodes
