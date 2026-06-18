# Instana Agent Air-Gapped Setup with Harbor

This document describes how to prepare and install the Instana Agent in an air-gapped OpenShift/Kubernetes environment by using Harbor as the internal container registry.

## 1. Overview

This setup includes the following steps:

* Pull required Instana images
* Tag images for Harbor
* Push images to Harbor
* Pull the Instana Agent Helm chart
* Apply OpenShift SCC permissions if needed
* Apply CRDs if available
* Install the Instana Agent with Helm
* Verify the installation

## 2. Image Preparation

These steps should be executed on a host that has access to the external Instana registries and Harbor.

### 2.1 Login to Instana Container Registry

```bash
$ docker login containers.instana.io -u _ -p <agentKey>
```

### 2.2 Pull Required Images

```bash
$ docker pull containers.instana.io/instana/release/agent/static:latest
$ docker pull icr.io/instana/instana-agent-operator:latest
$ docker pull icr.io/instana/k8sensor:latest
```

### 2.3 Tag Images for Harbor

Replace `harbor.company.local/instana` with your Harbor registry and project path.

```bash
$ docker tag containers.instana.io/instana/release/agent/static:latest harbor.company.local/instana/instana-agent:latest

$ docker tag icr.io/instana/instana-agent-operator:latest harbor.company.local/instana/instana-agent-operator:latest

$ docker tag icr.io/instana/k8sensor:latest harbor.company.local/instana/instana-k8sensor:latest
```

### 2.4 Push Images to Harbor

```bash
$ docker push harbor.company.local/instana/instana-agent:latest

$ docker push harbor.company.local/instana/instana-agent-operator:latest

$ docker push harbor.company.local/instana/instana-k8sensor:latest
```

If Harbor requires authentication for push, login first:

```bash
$ docker login harbor.company.local
```

## 3. Helm Chart Preparation

### 3.1 Pull Instana Agent Helm Chart

```bash
$ helm pull instana-agent --repo https://agents.instana.io/helm --untar
```

### 3.2 Check Chart Directory

```bash
$ ls -la instana-agent/
```

If the Helm chart will be used in a fully air-gapped environment, copy the `instana-agent/` directory to the target host.

## 4. OpenShift SCC Setup

If the distro is OpenShift, apply the following SCC permissions. Otherwise, skip this section.

### 4.1 Create Namespace

```bash
$ oc create namespace instana-agent --dry-run=client -o yaml | oc apply -f -
```

### 4.2 Apply SCC Permissions

```bash
$ oc adm policy add-scc-to-user privileged -z instana-agent -n instana-agent
$ oc adm policy add-scc-to-user anyuid -z instana-agent-remote -n instana-agent
```

## 5. CRD Setup

If the Helm chart contains a `crds` directory, apply the CRDs before Helm installation.

```bash
$ kubectl apply -f instana-agent/crds
```

If the `crds` directory does not exist, skip this section.

## 6. Helm Installation

### 6.1 Install Instana Agent with Harbor Images

Replace the following values before running the command:

* `<agentKey>`
* `ingress-red-saas.instana.io`
* `mip-back-test`
* `mip-gke-zone`
* `harbor.company.local/instana`

```bash
$ helm upgrade --install instana-agent ./instana-agent \
   --namespace instana-agent \
   --create-namespace \
   --set agent.key=<agentKey> \
   --set agent.endpointHost=ingress-red-saas.instana.io \
   --set agent.endpointPort=443 \
   --set cluster.name='mip-back-test' \
   --set zone.name='mip-gke-zone' \
   --set agent.env.INSTANA_AGENT_TAGS=openshift\,airgapped\,mip-back-test \
   --set k8s_sensor.deployment.enabled=true \
   --set k8s_sensor.image.name=harbor.company.local/instana/instana-k8sensor \
   --set k8s_sensor.image.tag=latest \
   --set k8s_sensor.image.pullPolicy=IfNotPresent \
   --set agent.image.name=harbor.company.local/instana/instana-agent \
   --set agent.image.tag=latest \
   --set agent.image.pullPolicy=IfNotPresent \
   --set controllerManager.image.name=harbor.company.local/instana/instana-agent-operator \
   --set controllerManager.image.tag=latest
```

## 7. Verification

### 7.1 Check Instana Agent Resources

```bash
$ oc get pods -n instana-agent
$ oc get all -n instana-agent
```

### 7.2 Check Instana Agent Logs

```bash
$ oc logs -n instana-agent -l app.kubernetes.io/name=instana-agent --tail=100
```

### 7.3 Check Kubernetes Sensor Logs

```bash
$ oc logs -n instana-agent -l app.kubernetes.io/name=k8sensor --tail=100
```

## 8. Manual Configuration

### 8.1 List InstanaAgent Resources

```bash
$ kubectl get ia --all-namespaces
```

### 8.2 Edit InstanaAgent Resource

```bash
$ kubectl edit ia instana-agent -n instana-agent
```

### 8.3 Example Output

```bash
root@worker-node:/home/ubuntu# kubectl get ia --all-namespaces
NAMESPACE       NAME            AGE
instana-agent   instana-agent   37m

root@worker-node:/home/ubuntu# kubectl edit ia instana-agent -n instana-agent
instanaagent.instana.io/instana-agent edited
```

## 9. Notes

### 9.1 Agent Tags

Agent tags are configured with the following Helm value:

```bash
  --set agent.pod.env[0].name=INSTANA_AGENT_TAGS \
  --set agent.pod.env[0].value="production" \

```

The commas are escaped with `\` because Helm parses comma-separated values inside `--set`.

