#!/bin/sh -ex

PROJECT_DIR="${HOME}/microponics"
IMAGE_PATH="${PROJECT_DIR}/install/images"
CHART_PATH="${PROJECT_DIR}/install/microponics"
CHART_NAME="microponics"
STORAGE_PATH="${HOME}/storage"
DEFAULT_NODE_NAME=`hostname`
SSH_KEY_PATH="${PROJECT_DIR}/keys/microponics.pub"
AUTH_KEY_FILE="${HOME}/.ssh/authorized_keys"

sudo systemctl start docker.service
microk8s start
microk8s enable storage
microk8s ctr image import ${IMAGE_PATH}/grow-controller-image.tar --no-unpack

if [ "${1}" = "master" ]; then
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
  if [ ! -f "${AUTH_KEY_FILE}" ] || [ -z "`cat ${AUTH_KEY_FILE} | grep -o microponics`" ]; then
    cat ${SSH_KEY_PATH} >> ${AUTH_KEY_FILE}
    chmod 644 ${AUTH_KEY_FILE}
  fi
  echo "Run the following command on the MASTER node to connect this node to the microponics cluster:"
  echo "~/microponics/add-node.sh `id -u -n` `ip route get 1.2.3.4 | awk '{print $7}' | head -n 1`"
fi
