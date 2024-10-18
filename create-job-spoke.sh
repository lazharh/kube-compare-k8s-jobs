#!/bin/bash

image=quay.io/bzhai/kube-compare-job:v20241018

delete_job(){
  oc delete job cluster-compare-reporter
}

create_job(){
  cat <<EOF | oc apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: cluster-compare-reporter
  namespace: default
spec:
  template:
    spec:
      restartPolicy: Never
      serviceAccountName: cluster-compare-reporter-sa
      containers:
        - name: reporter
          image: $image
          imagePullPolicy: Always
          command: ["/reporter-spoke.sh"]
  backoffLimit: 2

EOF
}

delete_job
create_job
