#!/bin/bash

image=quay.io/bzhai/kube-compare-job:v20241018

usage(){
  echo "Usage :   $0 <spoke cluster>"
  echo "   <spoke cluster> is optional, if not present, it will run cluster compare tool towards all the managed clusters."
  echo "Example :   $0 sno131"
  echo "Example :   $0"
}

delete_job(){
  spoke=$1
  oc delete job kube-compare-job-$spoke
}

create_job(){
  spoke=$1
  cat <<EOF | oc apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: kube-compare-job-$spoke
  namespace: default
spec:
  template:
    spec:
      restartPolicy: Never
      serviceAccountName: kube-compare-job-sa
      containers:
        - name: reporter
          image: $image
          imagePullPolicy: Always
          command: ["/reporter-hub.sh"]
          args:
            - $spoke
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
  delete_job $spoke
  create_job $1
fi
