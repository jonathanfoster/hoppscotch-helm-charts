#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly CLUSTER_NAME=chart-testing
readonly CONTAINER_NAME=ct
readonly CT_VERSION=v3.13.0
readonly K8S_VERSION=v1.33.1

cleanup() {
  echo "Removing ct container..."
  docker rm "${CONTAINER_NAME}" --force
  echo "Deleting Kind cluster..."
  kind delete cluster --name="${CLUSTER_NAME}"
}

create_kind_cluster() {
  kind create cluster --name "${CLUSTER_NAME}" --config test/kind-cluster.yaml --image "kindest/node:${K8S_VERSION}" --wait 60s
  docker exec "${CONTAINER_NAME}" mkdir /root/.kube
  docker cp "${HOME}/.kube/config" "${CONTAINER_NAME}:/root/.kube/config"
}

install_charts() {
  echo "Installing charts..."
  docker exec "${CONTAINER_NAME}" ct install
  echo
}

run_ct_container() {
  echo "Running ct container..."
  docker run --rm --interactive --detach --network host --name ct \
    --volume "$(pwd)/ct.yaml:/etc/ct/ct.yaml" \
    --volume "$(pwd):/workdir" \
    --workdir /workdir \
    "quay.io/helmpack/chart-testing:${CT_VERSION}" \
    cat
  echo
}

main() {
  run_ct_container
  trap cleanup EXIT
  create_kind_cluster
  install_charts
}

main
