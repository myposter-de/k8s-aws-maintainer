FROM ubuntu:20.04

ENV K8S_VERSION="1.14.8"
ENV TF_VERSION="0.12.16"
ENV HELM3_VERSION="3.1.0"

ENV KUBECONFIG="/root/.local-kube/config"

RUN apt-get update && apt-get install --no-install-recommends -y \
  mysql-client \
  screen \
  curl \
  jq \
  lzop \
  redis-tools \
  git \
  gpg \
  gpg-agent \
  groff \
  python3 \
  python-setuptools \
  python3-pip \
  unzip \
  make \
  rsync \
  && apt-get clean \
  && rm -rf /var/cache/apt/

# install aws-cli
RUN pip install awscli --upgrade

# install aws-iam-authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator \
  && chmod +x ./aws-iam-authenticator \
  && mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

# install yq, a yaml-query-tool
RUN curl -L https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64 -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq

# configure entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint

ENTRYPOINT ["entrypoint"]
CMD ["/bin/bash"]
# 623240091614.dkr.ecr.eu-central-1.amazonaws.com/myposter/external:maintainer
VOLUME /root/.aws
VOLUME /root/.kube

VOLUME /workspace
WORKDIR /workspace

# to start this image in the k8s cluster and access it directly you can run the following command:
# kubectl run --generator=run-pod/v1 --image=myposter/maintainer:latest --rm -it maintainer -- /bin/bash
# to delete this container, run 
# kubectl delete deployment maintainer

ENTRYPOINT ["entrypoint"]
