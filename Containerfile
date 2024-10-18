ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN dnf install git make -y \
    && wget -q https://go.dev/dl/go1.23.2.linux-amd64.tar.gz \
    && rm -rf /usr/local/go && tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz \
    && export PATH=$PATH:/usr/local/go/bin \
    && git clone https://github.com/openshift-kni/cnf-features-deploy.git \
    && git clone https://github.com/openshift/kube-compare.git \
    && cd kube-compare && export GOWORK=off && go mod vendor && make build && cp _output/bin/kubectl-cluster_compare /usr/local/bin/ \
    && oc cluster-compare -h

FROM ${BASE_IMAGE}
COPY --from=0 /usr/local/bin/kubectl-cluster_compare /usr/local/bin/kubectl-cluster_compare
COPY --from=0 /cnf-features-deploy/ztp/kube-compare-reference /kube-compare-reference

COPY custom /kube-compare-reference/custom
COPY metadata-lb.yaml /kube-compare-reference/
COPY metadata-mb.yaml /kube-compare-reference/

COPY reporter-hub.sh reporter-hub.sh
COPY reporter-spoke.sh reporter-spoke.sh
RUN chmod +x reporter-hub.sh
RUN chmod +x reporter-spoke.sh

CMD bash