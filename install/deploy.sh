#!/bin/sh -ex

PROJECT_DIR="${HOME}/microponics"
IMAGE_PATH="${PROJECT_DIR}/install/images"
CHART_PATH="${PROJECT_DIR}/install/microponics"
CHART_NAME="microponics"
STORAGE_PATH="${HOME}/storage"
DEFAULT_NODE_NAME=`hostname`
SSH_KEY_PATH="${PROJECT_DIR}/keys/microponics.pub"
AUTH_KEY_FILE="${HOME}/.ssh/authorized_keys"
HA_CONFIG_PATH="/var/snap/microk8s/current/args/ha-conf"

function setup_failure_domain() {
  ID=`ip route get 1.2.3.4 | awk '{ print $7 }' | grep -Eo '[0-9]+$'`
  set +ex
  if ! grep "failure-domain=" ${HA_CONFIG_PATH}; then
    echo "failure-domain=${ID}" > ${HA_CONFIG_PATH}
  fi
}

function start_snapd() {
  set +ex
  if ! (systemctl status snapd.service | grep 'Active: active'); then
    sudo systemctl start snapd.service
  fi
}

function start_or_restart_microk8s() {
  set +ex
  if microk8s status | grep 'not running'; then
    microk8s start
  else
    microk8s stop
    microk8s start
  fi
}

function setup_calico() {
  set +ex
  microk8s kubectl -n kube-system patch daemonset calico-node -p "`${PROJECT_DIR}/install/calico-patch.sh`"
  if microk8s kubectl -n kube-system get pods | grep "calico-*"; then
    kubectl -n kube-system delete pod `kubectl get pods -n kube-system | awk '/calico-*/ { print $1 }'`
  fi
}

sudo systemctl start docker.service
start_snapd
setup_failure_domain
start_or_restart_microk8s
${PROJECT_DIR}/reinforce.sh
microk8s enable storage
microk8s ctr image import ${IMAGE_PATH}/grow-controller-image.tar --no-unpack

if [ "${1}" = "master" ]; then
  microk8s kubectl label nodes ${DEFAULT_NODE_NAME} storage_node=true --overwrite
  if [ ! -d "${STORAGE_PATH}" ]; then
    mkdir -p ${STORAGE_PATH}
  fi

  microk8s enable dns ingress helm3
  setup_calico
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
