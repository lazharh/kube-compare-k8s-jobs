ARG BASE_IMAGE
BASE_IMAGE=registry.redhat.io/openshift4/ose-cli:latest
FROM registry.redhat.io/openshift4/kube-compare-artifacts-rhel9:latest as comparetool
#FROM  registry-proxy.engineering.redhat.com/rh-osbs/openshift-kube-compare-artifacts:v4.18 as comparetool
FROM registry.redhat.io/openshift4/ztp-site-generate-rhel8:v4.14 as rds414
#FROM registry.redhat.io/openshift4/ztp-site-generate-rhel8:v4.16 as rds416
FROM registry.redhat.io/openshift4/ztp-site-generate-rhel8:v4.18 as rds418

#FROM ${BASE_IMAGE}
#
#RUN dnf install git make -y \
#    && wget -q https://go.dev/dl/go1.23.2.linux-amd64.tar.gz \
#    && rm -rf /usr/local/go && tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz \
#    && export PATH=$PATH:/usr/local/go/bin \
#    && git clone https://github.com/openshift-kni/cnf-features-deploy.git \
#    && git clone https://github.com/openshift/kube-compare.git \
#    && cd kube-compare && export GOWORK=off && go mod vendor && make build && cp _output/bin/kubectl-cluster_compare /usr/local/bin/ \
#    && oc cluster-compare -h

FROM ${BASE_IMAGE}
RUN dnf install jq -y
COPY --from=comparetool /usr/share/openshift/linux_amd64/kube-compare.rhel8 /usr/local/bin/oc-cluster_compare
#can COPY --from=comparetool /usr/share/openshift/linux_amd64/kube-compare.rhel9 /usr/local/bin/oc-cluster_compare
COPY --from=rds414 /home/ztp/reference  /reference4.14
#COPY --from=rds416 /home/ztp/reference  /reference4.16
COPY --from=rds418 /home/ztp/reference  /reference4.18

COPY reporter-hub.sh reporter-hub.sh
COPY reporter-spoke.sh reporter-spoke.sh
RUN chmod +x reporter-hub.sh
RUN chmod +x reporter-spoke.sh

CMD bash
