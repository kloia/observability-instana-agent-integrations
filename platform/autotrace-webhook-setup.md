# Instana AutoTrace Webhook Setup

## Overview
The Instana AutoTrace webhook enables automatic instrumentation of applications without the need for manual agent configuration.

Once the webhook is installed, simply adding a label to your application **deployment / pod template** and restarting the pods is sufficient to begin collecting traces.

This method supports applications developed with:
- .NET  
- Node.js  
- Python  
- NGINX  
- Ruby  

**Official Documentation:**  
- IBM Docs: https://www.ibm.com/docs/en/instana-observability?topic=kubernetes-instana-autotrace-webhook
- Helm Chart: https://artifacthub.io/packages/helm/instana/instana-autotrace-webhook  



## Prerequisites
- Kubernetes or OpenShift cluster  
- Helm installed  
- Instana agent deployed and running  



## Installation

### Configuration Differences
When running the installation command, adjust the `openshift.enabled` flag based on your environment:

| Environment  | `--set openshift.enabled` |
|-------------|--------------------------|
| OpenShift   | `true`                   |
| Kubernetes  | `false` (or omit)        |



### Helm Command
```bash
helm install --create-namespace \
  --namespace instana-autotrace-webhook \
  instana-autotrace-webhook \
  --repo https://agents.instana.io/helm \
  instana-autotrace-webhook \
  --set autotrace.opt_in=true \
  --set openshift.enabled=true \
  --set webhook.imagePullCredentials.password=<download_key>
```

## Airgap / Restricted Network Setup

If the environment has no internet access:

- Download the Helm chart locally  
- Transfer it to the target environment  
- Install using the local chart path  



## Enable AutoTrace

Add the following label to the application deployment:
> Label must be added to the **deployment template / pod template**.

```yaml
spec:
  template:
    metadata:
      labels:
        instana-autotrace: "true"
```

Restart the deployment:
```bash
kubectl rollout restart deployment <deployment_name>
```

## Verification

- New pods should start with auto-instrumentation enabled  
- `instana-autotrace-init` container should be visible inside the pod (**in Terminated state**)  
- Traces should appear in the Instana UI after deployment restart  



## Definition of Done (DoD)

- [ ] Webhook is installed and running  
- [ ] Deployment includes `instana-autotrace: "true"` label  
- [ ] Application pods are restarted  
- [ ] Traces are visible in Instana  



## Summary

- Install webhook  
- Add label to deployment template  
- Restart deployment  
- Verify traces in Instana  

---

## Removing the Instrumentation

To remove the AutoTrace webhook from deployed applications and prevent it from being included in new applications, redeploy all higher-order resources that were formerly modified by the AutoTrace webhook.

The redeployment ensures that all AutoTrace configurations (init containers and environment variables) are removed from the resource specifications and pod templates.

Delete the existing deployment:

```bash
kubectl delete deployment <deployment-name> -n <deployment-ns>
```
Re-deploy the original resources:
```bash
kubectl apply -f <initial-deployment-spec.yaml>
```
