#!/bin/sh -ex

IMAGE_PATH="install/images"
CHART_PATH="install/microponics"
STORAGE_IMAGE="github.com/omnimeta/microponics/storage:local"
FRONTEND_IMAGE="github.com/omnimeta/microponics/frontend:local"
GROW_CTRL_IMAGE="github.com/omnimeta/microponics/grow-controller:local"

docker-compose build frontend grow-controller
docker-compose pull storage

if [ ! -d "${IMAGE_PATH}" ]; then
  mkdir -p ${IMAGE_PATH}
fi
docker save ${FRONTEND_IMAGE} > ${IMAGE_PATH}/frontend-image.tar
docker save ${GROW_CTRL_IMAGE} > ${IMAGE_PATH}/grow-controller-image.tar
docker save ${STORAGE_IMAGE} > ${IMAGE_PATH}/storage-image.tar

if [ -d "${CHART_PATH}" ]; then
  rm -r ${CHART_PATH}
fi
cp -r helm/dwc-cluster ${CHART_PATH}
