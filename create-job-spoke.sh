#!/bin/bash

image=quay.io/bzhai/kube-compare-job:v20241018

delete_job(){
  oc delete job kube-compare-job
}

create_job(){
  cat <<EOF | oc apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: kube-compare-job
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
          command: ["/reporter-spoke.sh"]
  backoffLimit: 2

EOF
}

delete_job
create_job
