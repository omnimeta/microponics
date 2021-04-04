#!/bin/sh -ex

IMAGE_PATH="install/images"
CHART_PATH="install/dwc-cluster"
STORAGE_IMAGE="mysql:8.0.23"
FRONTEND_IMAGE="github.com/omnimeta/dwc-cluster/frontend:local"
GROW_CTRL_IMAGE="github.com/omnimeta/dwc-cluster/grow-controller:local"

docker-compose build frontend grow-controller
docker-compose pull storage
docker save ${FRONTEND_IMAGE} > ${IMAGE_PATH}/frontend-image.tar
docker save ${GROW_CTRL_IMAGE} > ${IMAGE_PATH}/grow-controller-image.tar
docker save ${STORAGE_IMAGE} > ${IMAGE_PATH}/storage-image.tar

if [ -d "${CHART_PATH}" ]; then
  rm -r ${CHART_PATH}
fi
cp -r helm/dwc-cluster ${CHART_PATH}
