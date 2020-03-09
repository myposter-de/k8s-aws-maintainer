#!/bin/bash

# copy kube-config to ensure every container is running in it's own environment
if [ -f /root/.kube/config ] ; then
  mkdir -p /root/.local-kube
  cp -R /root/.kube/config /root/.local-kube/config
fi

exec "$@"