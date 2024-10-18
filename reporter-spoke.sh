#!/bin/bash

metadata="metadata.yaml"

echo "---------------------- comparing cluster with $metadata ----------------------"
echo "cluster info:"
oc get clusterversion
echo
oc get node

if [ $(oc api-resources --api-group=policy.open-cluster-management.io |wc -l) -eq 1 ]; then
  #not managed by Red Hat ACM
  echo
else
  echo "all policies applied on the cluster sorted by wave:"
  oc get policy -A -o=custom-columns=NS:.metadata.namespace,NAME:.metadata.name,"REMEDIATION ACTION":.spec.remediationAction,"COMPLIANCE STATE":.status.compliant,WAVE:.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave" --sort-by={.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave"}
fi

echo
echo "running oc cluster-compare -r /kube-compare-reference/$metadata:"
oc cluster-compare -r /kube-compare-reference/$metadata

exit 0


