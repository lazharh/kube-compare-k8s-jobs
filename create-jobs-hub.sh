#!/bin/bash

image=quay.io/lhalleb/kube-compare-job:latest

usage(){
  echo "Usage :   $0 <spoke cluster>"
  echo "   <spoke cluster> is optional, if not present, it will run cluster compare tool towards all the managed clusters."
  echo "Example :   $0 sno131"
  echo "Example :   $0"
}

delete_job(){
  spoke=$1
  oc delete job kube-compare-job -n $spoke
}

create_job(){
  spoke=$1
  #refver=$2
  cat <<EOF | oc apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: kube-compare-job
  namespace: $spoke
spec:
  template:
    spec:
      restartPolicy: Never
      serviceAccountName: jobrunner
      containers:
        - name: reporter
          image: $image
          imagePullPolicy: Always
          command: ["/reporter-hub.sh"]
          args:
            - $spoke
            #- $refver
  backoffLimit: 2

EOF
}

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
  usage
  exit
fi

if [ $# -lt 1 ]; then
  for spoke in $(oc get managedcluster.cluster.open-cluster-management.io -o jsonpath={..metadata.name} -l '!local-cluster')
  do
    delete_job $spoke
    create_job $spoke
  done
else
  delete_job $1
  create_job $1
fi
