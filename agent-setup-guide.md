**Helm Setup**


If the distro is only oc, apply the above step, otherwise skip it. 
```bash
$ oc adm policy add-scc-to-user privileged -z instana-agent
$ oc adm policy add-scc-to-user anyuid -z instana-agent-remote -n instana-agent
```


Option1 
```bash
helm upgrade --install instana-agent \
   --repo https://agents.instana.io/helm \
   --namespace instana-agent \
   --create-namespace \
   --set agent.key=hh1*********mWCyE \
   --set agent.downloadKey=rvA*******_0wg \
   --set agent.endpointHost=agent.instana.url \
   --set agent.endpointPort=443 \
   --set cluster.name='oc-mcloud2-cluster' \
   --set zone.name='prod-mcloud2' \
   --set agent.pod.limits.memory=1200Mi  \
   --set agent.pod.requests.memory=1200Mi  \
   instana-agent
```


Option2
```bash
helm upgrade --install instana-agent \
   --repo https://agents.instana.io/helm \
   --namespace instana-agent \
   --create-namespace \
   --set agent.key=hh1***********E \
   --set agent.downloadKey=rvA*********_0wg \
   --set agent.endpointHost=agent.instana.url \
   --set agent.endpointPort=443 \
   --set cluster.name='oc-mcloud2-cluster' \
   --set zone.name='prod-mcloud2' \
   --set agent.pod.limits.memory=1200Mi  \
   --set agent.pod.requests.memory=1200Mi  \
   --set k8s_sensor.deployment.pod.limits.cpu=1 \
   --set k8s_sensor.deployment.pod.limits.memory=768Mi \
   --set k8s_sensor.deployment.pod.requests.cpu=500m \
   --set k8s_sensor.deployment.pod.requests.memory=768Mi \
   instana-agent

```


**Operator Setup**

```bash
$ kubectl create namespace instana-agent

$ kubectl apply -f https://github.com/instana/instana-agent-operator/releases/latest/download/instana-agent-operator.yaml
```

$ vi instana-agent.customresource.yaml
```bash
apiVersion: instana.io/v1
kind: InstanaAgent
metadata:
  name: instana-agent
  namespace: instana-agent
spec:
  zone:
    name: prod-mcloud2
  cluster:
      name: oc-mcloud2-cluster
  agent:
    key: hh1*******xmWCyE
    downloadKey: rvA********_0wg
    endpointHost: agent.instana.url
    endpointPort: "443" 
    env: {}
    pod:
      requests:
        memory: 1200Mi
        cpu: "0.5"
      limits:
        memory: 1200Mi
        cpu: "1"
    configuration_yaml: |
      # You can leave this empty, or use this to configure your instana agent.
      # See https://docs.instana.io/setup_and_manage/host_agent/on/kubernetes/
```
   
```bash
$ kubectl apply -f instana-agent.customresource.yaml
```

Reference : https://www.ibm.com/docs/en/instana-observability/1.0.302?topic=openshift-installing-agent-red-hat#installing-by-using-the-operator



**Manuel Konfigurasyon**

```bash
$ kubectl get ia --all-namespaces


$ kubectl edit ia instana-agent -n instana-agent
```

Output Appearance: 
```bash
root@ip-172-31-46-125:/home/ubuntu# kubectl get ia --all-namespaces
NAMESPACE       NAME            AGE
instana-agent   instana-agent   37m
root@ip-172-31-46-125:/home/ubuntu# kubectl edit ia instana-agent -n instana-agent
instanaagent.instana.io/instana-agent edited
```


