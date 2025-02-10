#!/bin/bash

spoke=$1
#refver=$2

if [ $(oc get managedcluster.cluster.open-cluster-management.io   |grep $spoke | wc -l) -eq 1 ]; then
  metadata="metadata.yaml"

  echo "---------------------- comparing cluster: $spoke with $metadata ----------------------"
  oc get secret -n ${spoke} ${spoke}-admin-kubeconfig -o jsonpath={.data.kubeconfig} |base64 -d > kubeconfig-${spoke}.yaml
  export KUBECONFIG=kubeconfig-${spoke}.yaml
  echo "cluster info:"

  #export theVersion=$(oc get clusterversion version -ojsonpath='{.spec.desiredUpdate.version}')
  export theVersion=$(oc get clusterversion version | grep -v ^NAME | awk '{print $2}')
  echo $theVersion
  export refver=$(echo $theVersion | awk -F"." '{print $1"."$2}')
  echo
  oc get node
  echo
  echo "all policies applied on the cluster sorted by wave:"
  oc get policy -A -o=custom-columns=NS:.metadata.namespace,NAME:.metadata.name,"REMEDIATION ACTION":.spec.remediationAction,"COMPLIANCE STATE":.status.compliant,WAVE:.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave" --sort-by={.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave"}
  echo
  echo "running oc cluster-compare -r /reference${refver}/$metadata:"
  #ls -l /reference${refver}/
  export PATH=/usr/local/bin/:$PATH
  #oc cluster-compare -h
  #oc cluster-compare -r /reference${refver}/$metadata
  #echo "running /usr/local/bin/oc-cluster_compare -r https://raw.githubusercontent.com/openshift-kni/cnf-features-deploy/refs/heads/release-4.16/ztp/kube-compare-reference/metadata.yaml"
  #/usr/local/bin/oc-cluster_compare -r https://raw.githubusercontent.com/openshift-kni/cnf-features-deploy/refs/heads/release-4.16/ztp/kube-compare-reference/metadata.yaml

  /usr/local/bin/oc-cluster_compare -r /reference${refver}/$metadata
else
  "cluster $spoke not exist, please check."
fi

exit 0
