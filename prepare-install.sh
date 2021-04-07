#!/bin/sh -ex

PROJECT_DIR="${HOME}/microponics"
IMAGE_PATH="${PROJECT_DIR}/install/images"
CHART_PATH="${PROJECT_DIR}/install/microponics" # where the chart will be created
STORAGE_IMAGE="github.com/omnimeta/microponics/storage:local"
FRONTEND_IMAGE="github.com/omnimeta/microponics/frontend:local"
GROW_CTRL_IMAGE="github.com/omnimeta/microponics/grow-controller:local"

docker-compose build

if [ ! -d "${IMAGE_PATH}" ]; then
  mkdir -p ${IMAGE_PATH}
fi
docker save ${FRONTEND_IMAGE} > ${IMAGE_PATH}/frontend-image.tar
docker save ${GROW_CTRL_IMAGE} > ${IMAGE_PATH}/grow-controller-image.tar
docker save ${STORAGE_IMAGE} > ${IMAGE_PATH}/storage-image.tar

if [ -d "${CHART_PATH}" ]; then
  rm -r ${CHART_PATH}
fi
cp -r ${PROJECT_DIR}/helm/microponics ${CHART_PATH}
