# Instana Agent Integration Scripts & Setup Guides

A lightweight collection of scripts and guides focused on **Instana agent-side integrations**.

This repository covers how applications and environments are connected to Instana using agents, AutoTrace, and supporting automation tools.


## 📂 Structure

```bash
platform/   # Kubernetes / OpenShift (agent integrations)
monolith/   # VM / standalone integrations (e.g., NGINX)
scripts/    # automation utilities
```


## 📦 Content

#### Platform (Kubernetes / OpenShift)

- `platform/agent-setup-guide.md`  
- `platform/agent-setup-guide-airgap.md`  
- `platform/autotrace-webhook-setup.md`  
- `platform/*.md`  


#### Monolith

- `monolith/nginx/nginx-instana.conf`  


#### Scripts

- `scripts/instana-agent-label.sh`  
- `scripts/update_agent_mode.sh` / `.ps1`  
- `scripts/update_agent_host.sh`  


## 🧩 Scope

- Instana Agent installation & configuration  
- Kubernetes / OpenShift agent integrations  
- AutoTrace (Mutating Admission Webhook)  
- Monolithic / VM-based integrations  
- Airgap installation scenarios  
- Operational automation scripts  


## 📘 Notes

- All platform configurations are **Kubernetes-native and OpenShift-compatible**  
- Environment-specific differences (e.g., `openshift.enabled`) are handled in guides  
- Scripts are **reference implementations** → adapt before production use  


## 🤝 Contributing

Feel free to open issues or contribute improvements.


## 📎 References

- Instana Docs: https://www.ibm.com/docs/en/instana-observability  
- AutoTrace Webhook: https://artifacthub.io/packages/helm/instana/instana-autotrace-webhook  
- Kubernetes Admission Controllers: https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/  
