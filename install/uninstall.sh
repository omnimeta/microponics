#!/bin/sh

RELEASE_NAME="microponics"
CONTEXT="microk8s"
NAMESPACE="default"

function remove_storage_volumes() {
  microk8s kubectl config set-context ${CONTEXT} --namespace=${NAMESPACE}
  NUM_ITEMS=`microk8s kubectl get pvc | wc -l`
  CLAIMS=`microk8s kubectl get pvc | awk '{ print $1 }' | tail -n $(( ${NUM_ITEMS} - 1 )) | sed -e ':a;N;$!ba;s/\n/ /g'`
  for PVC in ${CLAIMS}; do
    microk8s kubectl delete ${PVC}
  done

  NUM_ITEMS=`microk8s kubectl get pv | wc -l`
  VOLUMES=`microk8s kubectl get pv | awk '{ print $1 }' | tail -n $(( ${NUM_ITEMS} - 1 )) | sed -e ':a;N;$!ba;s/\n/ /g'`
  for PV in ${VOLUMES}; do
    microk8s kubectl delete ${PV}
  done
}

remove_storage_volumes
if (microk8s helm3 list | grep ${RELEASE_NAME} | grep 'deployed'); then
  microk8s helm3 uninstall ${RELEASE_NAME}
fi
microk8s disable ingress dns storage helm3
microk8s stop
