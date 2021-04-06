#!/bin/sh -ex

IMAGE_PATH="images"
CHART_PATH="./microponics"
CHART_NAME="microponics"
STORAGE_PATH="${HOME}/storage"

microk8s start
microk8s enable storage helm3 ingress
microk8s ctr image import ${IMAGE_PATH}/storage-image.tar --no-unpack
microk8s ctr image import ${IMAGE_PATH}/grow-controller-image.tar --no-unpack
microk8s ctr image import ${IMAGE_PATH}/frontend-image.tar --no-unpack

# setup storage if this is a master node
if [ "${MASTER}" = "true" ]; then
  microk8s kubectl label nodes ubuntu storage_node=true --overwrite
  if [ ! -d "${STORAGE_PATH}" ]; then
    mkdir -p ${STORAGE_PATH}
  fi
  microk8s helm3 install ${CHART_NAME} ${CHART_PATH} -f ${CHART_PATH}/values.yaml --debug
else
  microk8s kubectl label nodes ubuntu storage_node=false --overwrite
fi

microk8s status --wait-ready

# need to map ingress IP to /etc/hosts
