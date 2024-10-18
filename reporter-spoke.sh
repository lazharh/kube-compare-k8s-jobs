#!/bin/bash

metadata="metadata.yaml"

echo "---------------------- comparing cluster with $metadata ----------------------"
oc get clusterversion
echo
oc get policy -A -o=custom-columns=NS:.metadata.namespace,NAME:.metadata.name,"REMEDIATION ACTION":.spec.remediationAction,"COMPLIANCE STATE":.status.compliant,WAVE:.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave" --sort-by={.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave"}
echo
echo "running oc cluster-compare -r /kube-compare-reference/$metadata:"
oc cluster-compare -r /kube-compare-reference/$metadata

exit 0


