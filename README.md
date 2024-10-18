## Purpose

On the hub cluster, create k8s job for each spoke cluster to run cluster-compare tool and log the output.

If only have permission for spoke cluster and not hub cluster, create k8s job on spoke cluster to run cluster-compare tool and log the output.

The source of the kube-compare tool: [kube-compare](https://github.com/openshift/kube-compare.git)
The source of the kube-compare-reference: [cnf-features-deploy](https://github.com/openshift-kni/cnf-features-deploy/tree/master/ztp/kube-compare-reference)

The image/script in this repo was created based on snapshot of the repos(main branch) above at the time when it was built(2024/10/18). 

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
# oc get job,pod

# oc logs -f kube-compare-job-sno131-crqm6
---------------------- comparing cluster: sno131 with metadata.yaml ----------------------
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.10   True        False         43d     Cluster version is 4.16.10

NS       NAME                                               REMEDIATION ACTION   COMPLIANCE STATE   WAVE
sno131   ztp-vdu.vdu-base-vdu2-4.16.10-p1a1-catalogs        inform               Compliant          1
...
sno131   ztp-vdu.vdu-base-vdu2-4.16.10-p1a1-tuning          inform               Compliant          100

running oc cluster-compare -r /kube-compare-reference/metadata.yaml:
W1018 16:44:04.670031     117 correlator.go:137] More then one template with same apiVersion, metadata_name, metadata_namespace, kind. By Default for each Cluster CR that is correlated to one of these templates the template with the least number of diffs will be used. To use a different template for a specific CR specify it in the diff-config (-c flag) Template names are: optional/ptp-config/PtpConfigDualCardGmWpc.yaml, optional/ptp-config/PtpConfigGmWpc.yaml, optional/ptp-config/PtpConfigMaster.yaml, optional/ptp-config/PtpConfigMasterForEvent.yaml
More then one template with same apiVersion, metadata_name, metadata_namespace, kind. By Default for each Cluster CR that is correlated to one of these templates the template with the least number of diffs will be used. To use a different template for a specific CR specify it in the diff-config (-c flag) Template names are: optional/ptp-config/PtpConfigForHA.yaml, optional/ptp-config/PtpConfigForHAForEvent.yaml
More then one template with same apiVersion, metadata_name, metadata_namespace, kind. By Default for each Cluster CR that is correlated to one of these templates the template with the least number of diffs will be used. To use a different template for a specific CR specify it in the diff-config (-c flag) Template names are: optional/ptp-config/PtpConfigSlave.yaml, optional/ptp-config/PtpConfigSlaveForEvent.yaml
More then one template with same apiVersion, metadata_name, metadata_namespace, kind. By Default for each Cluster CR that is correlated to one of these templates the template with the least number of diffs will be used. To use a different template for a specific CR specify it in the diff-config (-c flag) Template names are: optional/ptp-config/PtpConfigBoundary.yaml, optional/ptp-config/PtpConfigBoundaryForEvent.yaml
More then one template with same apiVersion, metadata_name, metadata_namespace, kind. By Default for each Cluster CR that is correlated to one of these templates the template with the least number of diffs will be used. To use a different template for a specific CR specify it in the diff-config (-c flag) Template names are: required/sriov-operator/SriovOperatorConfig.yaml, required/sriov-operator/SriovOperatorConfigForSNO.yaml
More then one template with same apiVersion, metadata_name, metadata_namespace, kind. By Default for each Cluster CR that is correlated to one of these templates the template with the least number of diffs will be used. To use a different template for a specific CR specify it in the diff-config (-c flag) Template names are: optional/ptp-config/PtpOperatorConfig.yaml, optional/ptp-config/PtpOperatorConfigForEvent.yaml
W1018 16:44:04.673797     117 compare.go:496] There may be an issue with the API resources exposed by the cluster. Found kind but missing group/version for ClusterRoleBinding.rbac.authorization.k8s.io/v1, StorageClass.storage.k8s.io/v1
W1018 16:44:04.673823     117 compare.go:425] Reference Contains Templates With Types (kind) Not Supported By Cluster: ClusterLogForwarder, LVMCluster, NMState, OperatorHub
W1018 16:44:05.570070     117 warnings.go:70] v1 is deprecated and should be removed in next three releases, use v2 instead
W1018 16:44:05.574327     117 warnings.go:70] v1alpha1 is deprecated and should be removed in the next release, use v2 instead
**********************************

Cluster CR: ptp.openshift.io/v1_PtpOperatorConfig_openshift-ptp_default
Reference File: optional/ptp-config/PtpOperatorConfig.yaml
Diff Output: diff -u -N /tmp/MERGED-3741765224/ptp-openshift-io-v1_ptpoperatorconfig_openshift-ptp_default /tmp/LIVE-4285408856/ptp-openshift-io-v1_ptpoperatorconfig_openshift-ptp_default
--- /tmp/MERGED-3741765224/ptp-openshift-io-v1_ptpoperatorconfig_openshift-ptp_default	2024-10-18 16:44:05.294042033 +0000
+++ /tmp/LIVE-4285408856/ptp-openshift-io-v1_ptpoperatorconfig_openshift-ptp_default	2024-10-18 16:44:05.294042033 +0000
@@ -6,3 +6,5 @@
 spec:
   daemonNodeSelector:
     node-role.kubernetes.io/master: ""
+  ptpEventConfig:
+    enableEventPublisher: true
...

No CRs are unmatched to reference CRs
Metadata Hash: 512a9bf2e57fd5a5c44bbdea7abb3ffd7739d4a1f14ef9021f6793d5cdf868f0
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

Summary
CRs with diffs: 0/48
No validation issues with the cluster
No CRs are unmatched to reference CRs
Metadata Hash: a6ef6ad91dce82dac63d75361130e72be9844c771014f8431152a80d32f2fb51
No patched CRs
```
