#!/bin/sh -e

NODE="${1}"
NODE_USER="ubuntu"
NODE_USER_PW="expirement98" # not confidential
SSH_KEY_PATH="${HOME}/microponics/keys/microponics"

if [ -z "${NODE}" ]; then
  echo "Error: incorrect usage"
  echo "Correct usage: ~/microponics/remove-node.sh <NODE_NAME_OR_PRIVATE_IP>"
  exit 1
fi

set +e
NODE_PRIVATE_IP=`echo ${NODE} | grep -Eo '^([0-9]{1,3}\.){3}[0-9]{1,3}$'` 
if [ ! -z "${NODE_PRIVATE_IP}" ]; then
  if [ -z "`microk8s kubectl get nodes -o wide | grep ${NODE_PRIVATE_IP}`" ]; then
    echo "Error: there is no node with private IP '${NODE_PRIVATE_IP}'"
    exit 1
  fi
else
  if [ -z "`microk8s kubectl get nodes -o wide | grep ${NODE}`" ]; then
    echo "Error: there is no node named '${NODE}'"
    exit 1
  fi
  NODE_PRIVATE_IP=`microk8s kubectl get nodes -o wide | grep ${NODE} | head -n 1 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'`
fi

if ping -c1 ${NODE_PRIVATE_IP}; then
  set -e
  eval `ssh-agent`
  chmod 600 ${SSH_KEY_PATH}
  ssh-add ${SSH_KEY_PATH}
  ssh -o "StrictHostKeyChecking no" ${NODE_USER}@${NODE_PRIVATE_IP} "echo ${NODE_USER_PW} | sudo -S /snap/bin/microk8s leave"
  eval `ssh-agent -k`
  sleep 10s
  set +e
fi

if [ ! -z "`microk8s kubectl get nodes -o wide | grep ${NODE_PRIVATE_IP}`" ]; then
  set -e
  NODE_NAME=`microk8s kubectl get nodes -o wide | grep ${NODE_PRIVATE_IP} | head -n 1 | awk '{print $1}'`
  echo "Completing removal"
  microk8s remove-node ${NODE_NAME} --force
sleep 20s
fi
echo "Removed node with IP '${NODE_PRIVATE_IP}'"
microk8s kubectl get nodes
