#!/bin/bash

spoke=$1

if [ $(oc get managedcluster.cluster.open-cluster-management.io   |grep $spoke | wc -l) -eq 1 ]; then
  metadata="metadata.yaml"

  echo "---------------------- comparing cluster: $spoke with $metadata ----------------------"
  LOGOUT_SERVER=false
  if  oc get secret -n ${spoke} ${spoke}-admin-kubeconfig ; then
     oc get secret -n ${spoke} ${spoke}-admin-kubeconfig -o jsonpath={.data.kubeconfig} |base64 -d > kubeconfig-${spoke}.yaml
     export KUBECONFIG=kubeconfig-${spoke}.yaml
  elif oc get secret -n ${spoke} ${spoke}-cluster-secret ; then
     export TOKEN=$(oc -n ${spoke} get secret ${spoke}-cluster-secret --template='{{index .data.config | base64decode}}' | jq -r '.bearerToken')
     export SERVER=$(oc -n ${spoke} get secret ${spoke}-cluster-secret --template='{{index .data.server | base64decode}}')
     export LOGOUT_SERVER=true
     oc login --insecure-skip-tls-verify=true --token=${TOKEN} ${SERVER}
  fi
  

  #export theVersion=$(oc get clusterversion version | grep -v ^NAME | awk '{print $2}')
  export theVersion=$(oc get clusterversion version -o json | jq -r '.status.history[0].version')
  echo "cluster info:"
  echo $theVersion
  export refver=$(echo $theVersion | awk -F"." '{print $1"."$2}')
  echo
  oc get node
  echo
  echo "all policies applied on the cluster sorted by wave:"
  oc get policy -A -o=custom-columns=NS:.metadata.namespace,NAME:.metadata.name,"REMEDIATION ACTION":.spec.remediationAction,"COMPLIANCE STATE":.status.compliant,WAVE:.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave" --sort-by={.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave"}
  echo
  echo "==========================================================="
  echo "running oc cluster-compare -r /reference${refver}/$metadata:"
  echo "==========================================================="
  echo
  #ls -l /reference${refver}/
  export PATH=/usr/local/bin/:$PATH
  #oc cluster-compare -h
  #oc cluster-compare -r /reference${refver}/$metadata
  #echo "running /usr/local/bin/oc-cluster_compare -r https://raw.githubusercontent.com/openshift-kni/cnf-features-deploy/refs/heads/release-4.16/ztp/kube-compare-reference/metadata.yaml"
  #/usr/local/bin/oc-cluster_compare -r https://raw.githubusercontent.com/openshift-kni/cnf-features-deploy/refs/heads/release-4.16/ztp/kube-compare-reference/metadata.yaml

  /usr/local/bin/oc-cluster_compare -r /reference${refver}/$metadata

  if [ LOGOUT_SERVER = true ]; then
     oc logout  -insecure-skip-tls-verify=true
  fi
else
 "cluster $spoke not exist, please check."
fi

exit 0
