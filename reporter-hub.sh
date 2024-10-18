#!/bin/bash

spoke=$1

if [ $(oc get managedcluster.cluster.open-cluster-management.io   |grep $spoke | wc -l) -eq 1 ]; then
  metadata="metadata.yaml"

  echo "---------------------- comparing cluster: $spoke with $metadata ----------------------"
  oc get secret -n ${spoke} ${spoke}-admin-kubeconfig -o jsonpath={.data.kubeconfig} |base64 -d > kubeconfig-${spoke}.yaml
  export KUBECONFIG=kubeconfig-${spoke}.yaml
  echo "cluster info:"
  oc get clusterversion
  echo
  oc get node
  echo
  echo "all policies applied on the cluster sorted by wave:"
  oc get policy -A -o=custom-columns=NS:.metadata.namespace,NAME:.metadata.name,"REMEDIATION ACTION":.spec.remediationAction,"COMPLIANCE STATE":.status.compliant,WAVE:.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave" --sort-by={.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave"}
  echo
  echo "running oc cluster-compare -r /kube-compare-reference/$metadata:"
  oc cluster-compare -r /kube-compare-reference/$metadata
else
  "cluster $spoke not exist, please check."
fi

exit 0