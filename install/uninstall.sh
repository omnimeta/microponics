#!/bin/sh

RELEASE_NAME="microponics"

if (microk8s helm3 list | grep ${RELEASE_NAME} | grep 'deployed'); then
  microk8s helm3 uninstall ${RELEASE_NAME}
fi
microk8s stop
