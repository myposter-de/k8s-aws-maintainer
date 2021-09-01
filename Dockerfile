FROM ubuntu:20.04

ENV K8S_VERSION="1.14.8"
ENV TF_VERSION="0.12.16"
ENV HELM_VERSION="2.14.3"
ENV HELM3_VERSION="3.1.0"
ENV AWS_CLI_VERSION="2.2.34"

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
  python-setuptools \
  python3-pip \
  unzip \
  make \
  rsync \
  && apt-get clean \
  && rm -rf /var/cache/apt/

# install aws-cli
RUN pip install \
    wheel \
    --upgrade

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip ./aws

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

# install helm-v3
RUN curl -LO https://get.helm.sh/helm-v${HELM3_VERSION}-linux-amd64.tar.gz \
  && mkdir ./helm3 \
  && tar -zxvf helm-v${HELM3_VERSION}-linux-amd64.tar.gz -C ./helm3 \
  && chmod +x ./helm3/linux-amd64/helm \
  && mv ./helm3/linux-amd64/helm /usr/local/bin/helm \
  && cp /usr/local/bin/helm /usr/local/bin/helm3 \
  && rm -rf ./helm3 helm-v${HELM3_VERSION}-linux-amd64.tar.gz

# install helm push plugin
RUN helm3 plugin install https://github.com/chartmuseum/helm-push

# install yq, a yaml-query-tool
RUN curl -L https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64 -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq

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
