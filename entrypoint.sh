#!/bin/bash

mkdir -p /root/.local-kube
touch /root/.local-kube/config
# copy kube-config to ensure every container is running in it's own environment
if [ -f /root/.kube/config ] ; then
  cp -R /root/.kube/config /root/.local-kube/config
fi

exec "$@"