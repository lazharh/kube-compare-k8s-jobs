## Purpose

On the hub cluster, create k8s job for each spoke cluster to run cluster-compare tool and log the output.

If only have permission for spoke cluster and not hub cluster, create k8s job on spoke cluster to run cluster-compare tool and log the output.

The source of the kube-compare tool: [kube-compare](https://github.com/openshift/kube-compare.git)

The source of the kube-compare-reference: [cnf-features-deploy](https://github.com/openshift-kni/cnf-features-deploy/tree/master/ztp/kube-compare-reference)

The image/script in this repo was created based on snapshot of the repos(main branch) above at the time when it was built(2024/10/18). 

## Usage

Create ServiceAccount and ClusterRoleBinding on either hub or spoke cluster depends on what permission you have or the lab situation:

```shell
oc apply -f service-account.yaml
oc apply -f cluster-role-binding.yaml
```

### K8s jobs on Hub cluster

This will create jobs for all the managed cluster on the hub:

```
# ./create-jobs-hub.sh

# oc get jobs
NAME                              COMPLETIONS   DURATION   AGE
kube-compare-job-sno131   1/1           8s         12m
kube-compare-job-sno132   1/1           7s         12m
kube-compare-job-sno133   1/1           6s         12m
kube-compare-job-sno146   1/1           6s         12m

# oc logs -f kube-compare-job-sno146-2zhd9
---------------------- comparing cluster: sno131 with metadata.yaml ----------------------
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.10   True        False         43d     Cluster version is 4.16.10

NS       NAME                                               REMEDIATION ACTION   COMPLIANCE STATE   WAVE
sno131   ztp-vdu.vdu-base-vdu2-4.16.10-p1a1-catalogs        inform               Compliant          1
sno131   ztp-vdu.acc100-vdu2-4.16.10-p1a1-subscriptions     inform               Compliant          2
...

Summary
CRs with diffs: 0/48
No validation issues with the cluster
No CRs are unmatched to reference CRs
Metadata Hash: 512a9bf2e57fd5a5c44bbdea7abb3ffd7739d4a1f14ef9021f6793d5cdf868f0
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
...
sno146   ztp-group-lb-du.lb-custom-common-config-custom-common-policy   inform               Compliant          200

...
running oc cluster-compare -r /kube-compare-reference/metadata.yaml:
...
Summary
CRs with diffs: 0/48
No validation issues with the cluster
No CRs are unmatched to reference CRs
Metadata Hash: a6ef6ad91dce82dac63d75361130e72be9844c771014f8431152a80d32f2fb51
No patched CRs
```
