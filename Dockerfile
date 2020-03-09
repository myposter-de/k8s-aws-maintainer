FROM ubuntu:19.04

ENV K8S_VERSION="1.14.8"
ENV TF_VERSION="0.12.16"
ENV HELM_VERSION="2.14.3"
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
  python \
  python-wheel \
  python-setuptools \
  python-pip \
  unzip \
  make \
  && apt-get clean \
  && rm -rf /var/cache/apt/

# install aws-cli
RUN pip install awscli --upgrade

# install aws-iam-authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator \
  && chmod +x ./aws-iam-authenticator \
  && mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/local/bin/kubectl

# install terraform
RUN curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
  && unzip terraform_${TF_VERSION}_linux_amd64.zip \
  && chmod +x ./terraform \
  && mv ./terraform /usr/local/bin/terraform \
  && rm terraform_${TF_VERSION}_linux_amd64.zip

# install-helm-v2
RUN curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  && mkdir ./helm \
  && tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz -C ./helm \
  && chmod +x ./helm/linux-amd64/helm \
  && mv ./helm/linux-amd64/helm /usr/local/bin/helm2 \
  && rm -rf ./helm helm-v${HELM_VERSION}-linux-amd64.tar.gz

# configure helm-tiller plugin
RUN helm2 init --client-only \
  && helm2 plugin install https://github.com/rimusz/helm-tiller \
  && helm2 tiller install

# install helm-v3
RUN curl -LO https://get.helm.sh/helm-v${HELM3_VERSION}-linux-amd64.tar.gz \
  && mkdir ./helm3 \
  && tar -zxvf helm-v${HELM3_VERSION}-linux-amd64.tar.gz -C ./helm3 \
  && chmod +x ./helm3/linux-amd64/helm \
  && mv ./helm3/linux-amd64/helm /usr/local/bin/helm \
  && cp /usr/local/bin/helm /usr/local/bin/helm3 \
  && rm -rf ./helm3 helm-v${HELM3_VERSION}-linux-amd64.tar.gz

# add helm-repo's
RUN helm3 repo add stable https://kubernetes-charts.storage.googleapis.com \
  && helm3 repo add incubator https://storage.googleapis.com/kubernetes-charts-incubator

# install helm push plugin
RUN helm3 plugin install https://github.com/chartmuseum/helm-push

# configure entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint

ENTRYPOINT ["entrypoint"]
CMD ["/bin/bash"]

VOLUME /root/.aws
VOLUME /root/.kube

VOLUME /workspace
WORKDIR /workspace

# to start this image in the k8s cluster and access it directly you can run the following command:
# kubectl run --generator=run-pod/v1 --image=myposter/maintainer:latest --rm -it maintainer -- /bin/bash
# to delete this container, run 
# kubectl delete deployment maintainer

ENTRYPOINT ["entrypoint"]
