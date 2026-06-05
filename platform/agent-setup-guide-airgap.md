**Helm Setup**


If the distro is only oc, apply the above step, otherwise skip it. 
```bash
$ oc adm policy add-scc-to-user privileged -z instana-agent
$ oc adm policy add-scc-to-user anyuid -z instana-agent-remote -n instana-agent
```


Option1 : All in Proxy (includes Both, Agent and Repository)
```bash
helm upgrade --install instana-agent \
   --repo https://agents.instana.io/helm \
   --namespace instana-agent \
   --create-namespace \
   --set agent.key=hh1*********mWCyE \
   --set agent.downloadKey=rvA*******_0wg \
   --set agent.endpointHost=agent.instana.url \
   --set agent.endpointPort=443 \
   --set cluster.name='oc-any-cluster' \
   --set zone.name='prod-any-zone' \
   --set agent.pod.limits.memory=1200Mi  \
   --set agent.pod.requests.memory=1200Mi  \
   --set agent.proxyHost='2.2.2.2'   \
   --set agent.proxyPort='3128' \
   --set agent.proxyUser='proxyuser' \
   --set agent.proxyPassword='password'  \
   instana-agent
```


Option2 : Seperated Proxy (includes only Repository or both)
```bash
helm upgrade --install instana-agent \
   --repo https://agents.instana.io/helm \
   --namespace instana-agent \
   --create-namespace \
   --set agent.key=hh1***********E \
   --set agent.downloadKey=rvA*********_0wg \
   --set agent.endpointHost=agent.instana.url \
   --set agent.endpointPort=443 \
   --set cluster.name='oc-any-cluster' \
   --set zone.name='prod-any-zone' \
   --set agent.pod.limits.memory=1000Mi  \
   --set agent.pod.requests.memory=1000Mi  \
   --set k8s_sensor.deployment.pod.limits.cpu=1 \
   --set k8s_sensor.deployment.pod.limits.memory=768Mi \
   --set k8s_sensor.deployment.pod.requests.cpu=500m \
   --set k8s_sensor.deployment.pod.requests.memory=768Mi \
   #--set agent.proxyHost='2.2.2.2' \                              # (Optional) Agent proxy host
   #--set agent.proxyPort='3128' \                                 # (Optional) Agent proxy port
# Repository Proxy Configuration (Used for Maven downloads
   --set agent.env.INSTANA_REPOSITORY_PROXY_ENABLED='true' \
   --set agent.env.INSTANA_REPOSITORY_PROXY_HOST='3.3.3.3' \
   --set agent.env.INSTANA_REPOSITORY_PROXY_PORT='3128' \
   --set agent.env.INSTANA_REPOSITORY_PROXY_USER='proxyuser' \
   --set agent.env.INSTANA_REPOSITORY_PROXY_PASSWORD='password'  \
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
    name: zone_name_here    # typically set as a domain-specific name (e.g., CRM, PAYMENT, CRM_DB, PAYMENT_KAFKA)
  cluster:
      name: oc-any-cluster
  agent:
    key: hh1*********CyE
    downloadKey: rvA*********g
    endpointHost: agent.instana.url
    endpointPort: "443" 
#    env:
#      - name: INSTANA_AGENT_PROXY_HOST                                      # (Optional) defines proxy between instana agent and instana backend (e.g., squid or similar)
#        value: "3.3.3.3"         
#      - name: INSTANA_AGENT_PROXY_PORT
#        value: "3128"
#      - name: INSTANA_REPOSITORY_PROXY_ENABLED                             # (Optional) defines proxy for downloading sensors and dependencies from repository
#        value: "true"
#      - name: INSTANA_REPOSITORY_PROXY_HOST                                 
#        value: "3.3.3.3"
#      - name: INSTANA_REPOSITORY_PROXY_PORT                                 
#        value: "3.3.3.3"     
#      - name: INSTANA_REPOSITORY_PROXY_USER
#        value: "proxy-user"
#      - name: INSTANA_REPOSITORY_PROXY_PASSWORD
#        value: "proxy-user-password"
#      - name: INSTANA_SHARED_REPOSITORY_MIRROR_USERNAME                               # (Optional) configure repository mirroring via nexus 
#        value: "nexus-username"
#      - name: INSTANA_SHARED_REPOSITORY_MIRROR_PASSWORD
#        value: "nexus-pasword"
#      - name: AGENT_RELEASE_REPOSITORY_MIRROR_USERNAME
#        value: "nexus-username"
#      - name: AGENT_RELEASE_REPOSITORY_MIRROR_PASSWORD
#        value: "nexus-pasword"
#      - name: INSTANA_SHARED_REPOSITORY_MIRROR_URL
#        value: "https://nexus.local/repository/instana-shared"
#      - name: AGENT_RELEASE_REPOSITORY_MIRROR_URL
#        value: "https://nexus.local/repository/agent-release"
      
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


