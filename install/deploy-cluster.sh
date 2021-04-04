#!/bin/sh -ex

IMAGE_PATH="images"
CHART_PATH="./dwc-cluster"
CHART_NAME="dwc-cluster"

microk8s start
microk8s enable dns storage helm3
microk8s ctr image import ${IMAGE_PATH}/storage-image.tar --no-unpack
microk8s ctr image import ${IMAGE_PATH}/grow-controller-image.tar --no-unpack
microk8s ctr image import ${IMAGE_PATH}/frontend-image.tar --no-unpack
microk8s helm3 install ${CHART_NAME} ${CHART_PATH} -f ${CHART_PATH}/values.yaml --debug
microk8s status --wait-ready
