#!/bin/sh -ex

IMAGE_PATH="images"
CHART_PATH="./microponics"
CHART_NAME="microponics"
STORAGE_PATH="${HOME}/storage"
DEFAULT_NODE_NAME=`hostname`
SSH_KEY_PATH="${HOME}/microponics/keys/microponics.pub"

sudo systemctl start docker.service
microk8s start
microk8s enable storage
microk8s ctr image import ${IMAGE_PATH}/grow-controller-image.tar --no-unpack

if [ "${MASTER}" = "true" ]; then
  microk8s kubectl label nodes ${DEFAULT_NODE_NAME} storage_node=true --overwrite
  if [ ! -d "${STORAGE_PATH}" ]; then
    mkdir -p ${STORAGE_PATH}
  fi

  microk8s enable ingress helm3
  microk8s ctr image import ${IMAGE_PATH}/storage-image.tar --no-unpack
  microk8s ctr image import ${IMAGE_PATH}/frontend-image.tar --no-unpack
  microk8s helm3 install ${CHART_NAME} ${CHART_PATH} -f ${CHART_PATH}/values.yaml --debug

  set +x
  echo "Stabilising deployment..."
  sleep 20s

else
  microk8s kubectl label nodes ${DEFAULT_NODE_NAME} storage_node=false --overwrite
  sudo systemctl start sshd.service
  set +x
  if [ -z "`cat ${HOME}/.ssh/authorized_keys | grep microponics`" ]; then
    cat ${SSH_KEY_PATH} >> ${HOME}/.ssh/authorized_keys
  fi
  echo "Run \`~/microponics/add-node.sh `hostname` `ip addr | awk 'print $7'`\` on the master node"
fi

microk8s status --wait-ready
