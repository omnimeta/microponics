#!/bin/sh -ex

IMAGE_PATH="images"
CHART_PATH="./microponics"
CHART_NAME="microponics"
STORAGE_PATH="${HOME}/storage"
DEFAULT_NODE_NAME=`hostname`

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
  echo "Stabilising deployment"
  sleep 20s

else
  microk8s kubectl label nodes ${DEFAULT_NODE_NAME} storage_node=false --overwrite
  set +x
  echo 'Run `microk8s add-node` on the MASTER node - this will output a command of the form:'
  echo '`microk8s join ip-XX-XX-XX-XX:XXXXXX/XXXXXXXXXXXXXXXXXXXXXXX` - run this command on THIS node to connect'
fi

microk8s status --wait-ready
