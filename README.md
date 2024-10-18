## Purpose

On the hub cluster, create k8s job for each spoke cluster to run cluster-compare tool and log the output.

If only have permission for spoke cluster and not hub cluster, create k8s job on spoke cluster to run cluster-compare tool and log the output.

## Usage

Create SA and ClusterRoleBinding on either hub or spoke cluster depends on what permission you have or the lab situation:

```shell
oc apply -f service-account.yaml
oc apply -f cluster-role-binding.yaml
```

### K8s jobs on Hub cluster

Create a job for a particular spoke cluster, for example cluster sno131:

```shell
spoke=sno131

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
```

Check logs:

```
# oc get job

# oc logs -f kube-compare-job-sno132-crqm6
---------------------- comparing cluster: sno132 with metadata.yaml ----------------------
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.15   True        False         18d     Cluster version is 4.16.15

NS       NAME                                                           REMEDIATION ACTION   COMPLIANCE STATE   WAVE
sno132   ztp-group-lb-du.lb-du-vdu-4.16.15-p4a1-config-operators        inform               Compliant          1
sno132   ztp-group-lb-du.lb-du-vdu-4.16.15-p4a1-subscription-policy     inform               NonCompliant       2
sno132   ztp-common.common-vdu-4.16.15-p4a1-config-policy               inform               Compliant          10
sno132   ztp-group-lb-du.lb-du-vdu-4.16.15-p4a1-config-policy           inform               Compliant          100
sno132   ztp-group-lb-du.lb-custom-common-config-custom-common-policy   inform               Compliant          200

W1015 18:09:32.500329     149 compare.go:496] There may be an issue with the API resources exposed by the cluster. Found kind but missing group/version for StorageClass.storage.k8s.io/v1
W1015 18:09:33.213363     149 warnings.go:70] v1 is deprecated and should be removed in next three releases, use v2 instead
W1015 18:09:33.218086     149 warnings.go:70] v1alpha1 is deprecated and should be removed in the next release, use v2 instead
Summary
CRs with diffs: 0/48
No validation issues with the cluster
No CRs are unmatched to reference CRs
Metadata Hash: a6ef6ad91dce82dac63d75361130e72be9844c771014f8431152a80d32f2fb51
No patched CRs
```

Quicker way to create jobs for all managed clusters:

```
# ./create-jobs-hub.sh

# oc get jobs
NAME                              COMPLETIONS   DURATION   AGE
kube-compare-job-sno131   1/1           8s         12m
kube-compare-job-sno132   1/1           7s         12m
kube-compare-job-sno133   1/1           6s         12m
kube-compare-job-sno146   1/1           6s         12m

# oc logs -f kube-compare-job-sno146-2zhd9
---------------------- comparing cluster: sno146 with metadata.yaml ----------------------
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.12   True        False         20d     Cluster version is 4.16.12

NS       NAME                                                           REMEDIATION ACTION   COMPLIANCE STATE   WAVE
sno146   ztp-group-lb-du.lb-du-vdu-4.16.12-p3a10-config-operators       inform               Compliant          1
sno146   ztp-group-lb-du.lb-du-vdu-4.16.12-p3a10-subscription-policy    inform               NonCompliant       2
sno146   ztp-common.common-vdu-4.16.12-p3a10-config-policy              inform               Compliant          10
sno146   ztp-group-lb-du.lb-du-vdu-4.16.12-p3a10-config-policy          inform               Compliant          100
sno146   ztp-group-lb-du.lb-custom-common-config-custom-common-policy   inform               Compliant          200

W1015 18:09:33.573667     132 compare.go:496] There may be an issue with the API resources exposed by the cluster. Found kind but missing group/version for StorageClass.storage.k8s.io/v1
W1015 18:09:34.358206     132 warnings.go:70] v1 is deprecated and should be removed in next three releases, use v2 instead
W1015 18:09:34.362751     132 warnings.go:70] v1alpha1 is deprecated and should be removed in the next release, use v2 instead
Summary
CRs with diffs: 0/48
No validation issues with the cluster
No CRs are unmatched to reference CRs
Metadata Hash: a6ef6ad91dce82dac63d75361130e72be9844c771014f8431152a80d32f2fb51
No patched CRs
```

### K8s jobs on Spoke cluster

If you only have permission to a particular spoke cluster:

```
# ./create-job-spoke.sh

# oc get jobs
NAME                       COMPLETIONS   DURATION   AGE
kube-compare-job   1/1           8s         12m

# oc logs -f kube-compare-job-5sv98
---------------------- comparing cluster with metadata.yaml ----------------------
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.12   True        False         22d     Cluster version is 4.16.12

NS       NAME                                                           REMEDIATION ACTION   COMPLIANCE STATE   WAVE
sno146   ztp-group-lb-du.lb-du-vdu-4.16.12-p3a10-config-operators       inform               Compliant          1
sno146   ztp-group-lb-du.lb-du-vdu-4.16.12-p3a10-subscription-policy    inform               NonCompliant       2
sno146   ztp-common.common-vdu-4.16.12-p3a10-config-policy              inform               Compliant          10
sno146   ztp-group-lb-du.lb-du-vdu-4.16.12-p3a10-config-policy          inform               Compliant          100
sno146   ztp-group-lb-du.lb-custom-common-config-custom-common-policy   inform               Compliant          200

W1017 17:03:36.118518     188 compare.go:496] There may be an issue with the API resources exposed by the cluster. Found kind but missing group/version for StorageClass.storage.k8s.io/v1
W1017 17:03:36.285262     188 warnings.go:70] v1 is deprecated and should be removed in next three releases, use v2 instead
W1017 17:03:36.289071     188 warnings.go:70] v1alpha1 is deprecated and should be removed in the next release, use v2 instead
Summary
CRs with diffs: 0/48
No validation issues with the cluster
No CRs are unmatched to reference CRs
Metadata Hash: a6ef6ad91dce82dac63d75361130e72be9844c771014f8431152a80d32f2fb51
No patched CRs
```
