#!/bin/bash

# run the maintainer in your current directory

docker run --rm -it \
  -v $(pwd):/workspace \
  -v ${HOME}/.kube:/root/.kube \
  -v ${HOME}/.aws:/root/.aws \
  myposter/maintainer:latest \
  $@