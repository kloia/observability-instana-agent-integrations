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

- `scripts/instana-agent-installation.sh` / `.ps1` → see [Instana Agent Installation](#-instana-agent-installation-linux--windows-scripts) below
- `scripts/instana-agent-label.sh`  
- `scripts/update_agent_mode.sh` / `.ps1`  
- `scripts/update_agent_host.sh`  


## 🚀 Instana Agent Installation (Linux / Windows Scripts)

### Which install method should I use?

There are two legitimate ways to install the Instana host agent on Linux — pick based on whether the box can reach Instana's package servers:

- **Server has internet access (default, recommended)** → just use **Instana's own official auto-installer**. It sets up the yum/apt repo and downloads + installs the package itself — no manual package staging needed:

  ```bash
  curl -o setup_agent.sh https://setup.instana.io/agent
  chmod 700 ./setup_agent.sh
  sudo -E ./setup_agent.sh -a <agent-key> -d <download-key> -e <endpoint>:<port> -t static -s -y
  ```

  `<endpoint>` follows the [SaaS vs self-hosted](#backend-endpoint-saas-vs-self-hosted) rule below (e.g. `ingress-green-saas.instana.io:443`). Get the exact ready-to-run command (keys included) from Instana UI → **More → Agents → Installing Instana Agents**.

- **Air-gapped / offline / no route to Instana's repo, or you need controlled/manual package staging** → use **this repository's `scripts/instana-agent-installation.sh` / `.ps1`** instead. Unlike the official installer above, these scripts do **not** reach out to Instana's repo servers — they assume you've already placed the package file locally and only handle the local install + configuration (mode, zone, tag, mvn-settings, multi-backend). This is the path documented in the rest of this section.

### Location

The scripts live in `scripts/`:

- `scripts/instana-agent-installation.sh` (Linux)
- `scripts/instana-agent-installation.ps1` (Windows)

`cd` into that folder first so the relative paths in the examples below work as-is:

```bash
cd scripts/
```

```powershell
cd scripts\
```

### Supported platforms

- **Linux**: RHEL family (`rpm`), Debian family (`dpkg`) — architectures `x86_64`, `aarch64`, `s390x`, `ppc64le`. macOS, AIX and Solaris are explicitly rejected by the script.
- **Windows**: package installed silently via the Instana `.exe` installer.

### Backend endpoint: SaaS vs self-hosted

Which host/port you give the script depends on where your Instana backend runs — pick the row that matches your tenant:

| Deployment | Endpoint format | Example |
| --- | --- | --- |
| **Instana SaaS** (default, most common) | `ingress-<color>-saas.instana.io` | `ingress-blue-saas.instana.io` |
| **Self-hosted / on-prem Instana** | `agent-acceptor.instana.<your-company-domain>` | `agent-acceptor.instana.example.com` |

- If you're on **SaaS**, you don't need to set anything — the scripts already default to the SaaS address. Confirm the exact value under your Instana UI → **More → Agents → Installing Instana Agents** if unsure.
- If you're on a **self-hosted** backend, you must pass it explicitly with `-b`/`-P` (Linux) or `-INSTANA_AGENT_ENDPOINT`/`-INSTANA_AGENT_ENDPOINT_PORT` (Windows) — get the exact hostname from your Instana platform admin or your self-hosted Instana's agent install page.

### Environment variables

Set these **before** running either script instead of passing them as CLI flags — both scripts fall back to these env vars, and it keeps secrets out of shell history / process listings. Everything here is optional except the agent key; unset values fall back to their defaults (SaaS endpoint, download key = agent key).

**Linux:**

```bash
export INSTANA_AGENT_KEY=<agent-key>            # required (or pass -a)
export INSTANA_DOWNLOAD_KEY=<agent-key>         # optional, defaults to INSTANA_AGENT_KEY
export INSTANA_AGENT_HOST=<backend-host>        # optional, defaults to SaaS — e.g. agent-acceptor.instana.your-domain.com
export INSTANA_AGENT_PORT=<backend-port>        # optional, defaults to 443
```

**Windows (PowerShell):**

```powershell
$env:INSTANA_AGENT_KEY = "<agent-key>"                      # required (or pass -INSTANA_AGENT_KEY)
$env:INSTANA_DOWNLOAD_KEY = "<agent-key>"                   # optional, defaults to INSTANA_AGENT_KEY
$env:INSTANA_AGENT_ENDPOINT = "<backend-host>"              # optional, defaults to SaaS — e.g. agent-acceptor.instana.your-domain.com
$env:INSTANA_AGENT_ENDPOINT_PORT = "<backend-port>"         # optional, defaults to 443
```

### Prerequisites

#### Linux

1. Must be run as **root** (or via `sudo`) — the script exits immediately otherwise.
1. Download the raw Instana agent package for your distro **before** running the script (the script does not download it for you):

   - Go to Instana UI → **More → Agents → Installing Instana Agents**, pick your distro/architecture, and copy the exact `.rpm`/`.deb` download link shown there (it's versioned, e.g. `.../instana-team-release-agent-public-rpm-virtual/x86_64/instana-agent-static-<version>.x86_64.rpm` — it changes with each release, don't hardcode it).
   - Fetch it from the server with that link, authenticating with your **download key** as the password (username is literally `_`):

   ```bash
   curl -u "_:<download-key>" -LO https://packages.instana.io/instana-team-release-agent-public-rpm-virtual/x86_64/instana-agent-static-<version>.x86_64.rpm
   ```

   `-L` matters — the link may redirect. Pass the downloaded file's path via `-p` to the script.

   ⚠️ If you're on a **self-hosted** backend, the package host may not be `packages.instana.io` at all — get the right link/key from your own on-prem Instana UI, rather than assuming this SaaS one.

   On **air-gapped / offline hosts** without internet access, `curl` against `packages.instana.io` won't work — get the package from your internal artifact repository/mirror instead (or copy it over via SCP/USB) and just point `-p` at wherever it ends up locally; the script itself doesn't care how the file got there.
1. Make the script executable:

   ```bash
   chmod +x instana-agent-installation.sh
   ```

1. (Optional) Set the [environment variables](#environment-variables) above instead of passing `-a`/`-d`/`-b`/`-P` on the command line.

#### Windows

1. Open PowerShell **as Administrator** — the installer writes to `C:\Program Files\Instana` and otherwise fails silently.
1. Allow the script to run for the current session (default PowerShell execution policy blocks `.ps1` files):

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

1. Download the Instana agent Windows installer before running the script — same idea as Linux: go to Instana UI → **More → Agents → Installing Instana Agents**, pick Windows, and grab the exact `.exe` download link shown there (it's versioned, e.g. `.../instana-team-release-generic-virtual/com/instana/agent-assembly-offline/<version>/agent-assembly-offline-<version>-windows-64bit-offline.exe` — it changes with each release, don't hardcode it). Open that link in a browser, authenticate with your Instana credentials/download key when prompted, and save the `.exe` locally. If you're on a **self-hosted** backend, get the link from your own on-prem Instana UI instead.

   On **air-gapped / offline hosts**, grab the `.exe` from your internal artifact repository/mirror instead (or copy it over some other way) — just point `-INSTANA_PACKAGE_PATH` at wherever it ends up locally.

1. (Optional) Set the [environment variables](#environment-variables) above instead of passing `-INSTANA_AGENT_KEY`/`-INSTANA_DOWNLOAD_KEY`/`-INSTANA_AGENT_ENDPOINT`/`-INSTANA_AGENT_ENDPOINT_PORT` on the command line.

### Linux Installation

#### Linux Configuration Options

| Flag | Env var equivalent | Default | Description |
| --- | --- | --- | --- |
| `-a` | `INSTANA_AGENT_KEY` | — (required) | Agent key — prefer the env var over `-a` (CLI args leak into shell history / `ps`) |
| `-d` | `INSTANA_DOWNLOAD_KEY` | same as `-a` | Download key — prefer the env var over `-d`, same reason |
| `-b` | `INSTANA_AGENT_HOST` | `ingress-blue-saas.instana.io` | Backend host — set this for a self-hosted/on-prem Instana backend |
| `-P` | `INSTANA_AGENT_PORT` | `443` | Backend port |
| `-e` | — | "" | First backend host for **multi-backend** setups (leave empty for single-backend) |
| `-g` | — | "" | Second backend host for **multi-backend** setups (leave empty for single-backend) |
| `-p` | — | — (required) | Local path to the downloaded package |
| `-u` | — | "" | Path to a pre-configured `mvn-settings.xml` |
| `-t` | — | "" | Agent tag |
| `-z` | — | "" | Agent zone |
| `-m` | — | `infra` | Agent mode: `apm` \| `aws` \| `infra` |
| `-n` | — | off | Use systemd `notify` service type instead of `simple` |

> `-b`/`-P` set the **single-backend** endpoint (SaaS or self-hosted). `-e`/`-g` are a separate, independent mechanism for **multi-backend** setups (they write two backend config files instead of one) — don't mix the two unless you actually run a dual-backend setup.

#### Linux Example Usage

> The examples below export the agent/download key first and omit `-a`/`-d` on the command line, so secrets don't end up in shell history or `ps` output. Passing `-a`/`-d` directly still works if you'd rather do that.

##### Single backend, with tag and zone (Linux)

```bash
export INSTANA_AGENT_KEY=agent-key
export INSTANA_DOWNLOAD_KEY=agent-key
./instana-agent-installation.sh -t agent-tag -z agent-zone -p package-path
```

##### Self-hosted / on-prem backend (Linux)

```bash
export INSTANA_AGENT_KEY=agent-key
export INSTANA_DOWNLOAD_KEY=agent-key
./instana-agent-installation.sh -t agent-tag -z agent-zone -p package-path -b agent-acceptor.instana.your-domain.com -P 443
```

##### Multi-backend, two Instana endpoints (Linux)

```bash
export INSTANA_AGENT_KEY=agent-key
export INSTANA_DOWNLOAD_KEY=agent-key
./instana-agent-installation.sh -t agent-tag -z agent-zone -p package-path -e first-host -g second-host
```

##### With a pre-configured mvn-settings file (Linux)

```bash
export INSTANA_AGENT_KEY=agent-key
export INSTANA_DOWNLOAD_KEY=agent-key
./instana-agent-installation.sh -t agent-tag -z agent-zone -p package-path -e first-host -g second-host -u mvn-settings.xml
```

### Windows Installation

#### Windows Configuration Options

| Parameter | Default | Description |
| --- | --- | --- |
| `INSTANA_AGENT_KEY` | `$env:INSTANA_AGENT_KEY` | Agent key — prefer `$env:INSTANA_AGENT_KEY` over the flag (CLI args leak into shell history / process listings) |
| `INSTANA_DOWNLOAD_KEY` | `$env:INSTANA_DOWNLOAD_KEY`, then falls back to `INSTANA_AGENT_KEY` | Download key — prefer the env var over the flag, same reason |
| `INSTANA_PACKAGE_PATH` | — (required) | Local path to the downloaded installer |
| `INSTANA_AGENT_ENDPOINT` | `ingress-blue-saas.instana.io` | Backend host — set this for a self-hosted/on-prem Instana backend |
| `INSTANA_AGENT_ENDPOINT_PORT` | `443` | Backend port |
| `INSTANA_AGENT_HOST_ONE` | "" | First backend host for **multi-backend** setups (leave empty for single-backend) |
| `INSTANA_AGENT_HOST_TWO` | "" | Second backend host for **multi-backend** setups (leave empty for single-backend) |
| `INSTANA_MVN_CONF_PATH` | "" | Path to a pre-configured `mvn-settings.xml` |
| `AGENT_TAG` | "" | Agent tag |
| `AGENT_ZONE` | "" | Agent zone |

> `INSTANA_AGENT_ENDPOINT`/`_PORT` set the **single-backend** endpoint (SaaS or self-hosted) used at install time. `INSTANA_AGENT_HOST_ONE`/`_TWO` are a separate, independent mechanism for **multi-backend** setups (they write two backend config files after install) — don't mix the two unless you actually run a dual-backend setup.

#### Windows Example Usage

> The examples below set `$env:INSTANA_AGENT_KEY`/`$env:INSTANA_DOWNLOAD_KEY` first and omit `-INSTANA_AGENT_KEY`/`-INSTANA_DOWNLOAD_KEY` on the command line, so secrets don't end up in shell history or process listings. Passing them as flags still works if you'd rather do that.

##### Single backend, with tag and zone (Windows)

```powershell
$env:INSTANA_AGENT_KEY = "agent_key"
$env:INSTANA_DOWNLOAD_KEY = "download_key"
.\instana-agent-installation.ps1 -AGENT_ZONE agentzone -AGENT_TAG agenttag -INSTANA_PACKAGE_PATH exepackagepath
```

##### Self-hosted / on-prem backend (Windows)

```powershell
$env:INSTANA_AGENT_KEY = "agent_key"
$env:INSTANA_DOWNLOAD_KEY = "download_key"
.\instana-agent-installation.ps1 -AGENT_ZONE agentzone -AGENT_TAG agenttag -INSTANA_PACKAGE_PATH exepackagepath -INSTANA_AGENT_ENDPOINT agent-acceptor.instana.your-domain.com -INSTANA_AGENT_ENDPOINT_PORT 443
```

##### Multi-backend, two Instana endpoints (Windows)

```powershell
$env:INSTANA_AGENT_KEY = "agent_key"
$env:INSTANA_DOWNLOAD_KEY = "download_key"
.\instana-agent-installation.ps1 -AGENT_ZONE agentzone -AGENT_TAG agenttag -INSTANA_AGENT_HOST_ONE firsthost -INSTANA_AGENT_HOST_TWO secondhost -INSTANA_PACKAGE_PATH exepackagepath
```

##### With a pre-configured mvn-settings file (Windows)

```powershell
$env:INSTANA_AGENT_KEY = "agent_key"
$env:INSTANA_DOWNLOAD_KEY = "download_key"
.\instana-agent-installation.ps1 -AGENT_ZONE agentzone -AGENT_TAG agenttag -INSTANA_AGENT_HOST_ONE firsthost -INSTANA_AGENT_HOST_TWO secondhost -INSTANA_PACKAGE_PATH exepackagepath -INSTANA_MVN_CONF_PATH mvnsettingspath
```

#### Windows Uninstall

- Remove Instana from **Add or Remove Programs**
- Delete the leftover directory at `C:\Program Files\Instana`


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
