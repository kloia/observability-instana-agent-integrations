# Instana Agent Installation (Linux rpm/deb & Windows)

## Location

The scripts live in [`scripts/`](../scripts/):

- `scripts/instana-agent-installation.sh` (Linux)
- `scripts/instana-agent-installation.ps1` (Windows)

`cd` into that folder first so the relative paths in the examples below work as-is:

```bash
cd scripts/
```

```powershell
cd scripts\
```

## Supported platforms

- **Linux**: RHEL family (`rpm`), Debian family (`dpkg`) — architectures `x86_64`, `aarch64`, `s390x`, `ppc64le`. macOS, AIX and Solaris are explicitly rejected by the script.
- **Windows**: package installed silently via the Instana `.exe` installer.

## Backend endpoint: SaaS vs self-hosted

Which host/port you give the script depends on where your Instana backend runs — pick the row that matches your tenant:

| Deployment | Endpoint format | Example |
| --- | --- | --- |
| **Instana SaaS** (default, most common) | `ingress-<color>-saas.instana.io` | `ingress-blue-saas.instana.io` |
| **Self-hosted / on-prem Instana** | `agent-acceptor.instana.<your-company-domain>` | `agent-acceptor.instana.example.com` |

- If you're on **SaaS**, you don't need to set anything — the scripts already default to the SaaS address. Confirm the exact value under your Instana UI → **More → Agents → Installing Instana Agents** if unsure.
- If you're on a **self-hosted** backend, you must pass it explicitly with `-b`/`-P` (Linux) or `-INSTANA_AGENT_ENDPOINT`/`-INSTANA_AGENT_ENDPOINT_PORT` (Windows) — get the exact hostname from your Instana platform admin or your self-hosted Instana's agent install page.

## Prerequisites

### Linux

1. Must be run as **root** (or via `sudo`) — the script exits immediately otherwise.
1. Download the Instana agent package for your distro **before** running the script (the script does not download it for you):

   ```bash
   curl -LO https://<download-key>:<agent-key>@packages.instana.io/<path-to-package>
   ```

   Quick tip: RHEL → `.rpm` package, Debian/Ubuntu → `.deb` package.

   On **air-gapped / offline hosts** without internet access, `curl` against `packages.instana.io` won't work — get the package from your internal artifact repository/mirror instead (or copy it over via SCP/USB) and just point `-p` at wherever it ends up locally; the script itself doesn't care how the file got there.
1. Make the script executable:

   ```bash
   chmod +x instana-agent-installation.sh
   ```

1. (Optional) Instead of passing flags, you can export any of these before running the script — the script falls back to the SaaS defaults only if they're unset:

   ```bash
   export INSTANA_AGENT_KEY=<agent-key>
   export INSTANA_DOWNLOAD_KEY=<agent-key>
   export INSTANA_AGENT_HOST=<self-hosted-backend-host>   # e.g. agent-acceptor.instana.your-domain.com
   export INSTANA_AGENT_PORT=<self-hosted-backend-port>
   ```

   Same effect as passing `-b`/`-P` on the command line (see the options table below) — useful for **self-hosted / on-prem Instana backends**, where the endpoint isn't the SaaS default.

### Windows

1. Open PowerShell **as Administrator** — the installer writes to `C:\Program Files\Instana` and otherwise fails silently.
1. Allow the script to run for the current session (default PowerShell execution policy blocks `.ps1` files):

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

1. Download the Instana agent Windows installer before running the script — get the `.exe` from your Instana tenant's install page and note its local path.

   On **air-gapped / offline hosts**, grab the `.exe` from your internal artifact repository/mirror instead (or copy it over some other way) — just point `-INSTANA_PACKAGE_PATH` at wherever it ends up locally.

## Linux Installation

### Linux Configuration Options

| Flag | Env var equivalent | Default | Description |
| --- | --- | --- | --- |
| `-a` | `INSTANA_AGENT_KEY` | — (required) | Agent key |
| `-d` | `INSTANA_DOWNLOAD_KEY` | same as `-a` | Download key |
| `-b` | `INSTANA_AGENT_HOST` | `ingress-blue-saas.instana.io` | Backend host — set this for a self-hosted/on-prem Instana backend |
| `-P` | `INSTANA_AGENT_PORT` | `443` | Backend port |
| `-e` | — | "" | First backend host for **multi-backend** setups (leave empty for single-backend) |
| `-g` | — | "" | Second backend host for **multi-backend** setups (leave empty for single-backend) |
| `-p` | — | — (required) | Local path to the downloaded package |
| `-u` | — | "" | Path to a pre-configured `mvn-settings.xml` |
| `-t` | — | "" | Agent tag |
| `-z` | — | "" | Agent zone |
| `-m` | — | `apm` | Agent mode: `apm` \| `aws` \| `infra` |
| `-n` | — | off | Use systemd `notify` service type instead of `simple` |

> `-b`/`-P` set the **single-backend** endpoint (SaaS or self-hosted). `-e`/`-g` are a separate, independent mechanism for **multi-backend** setups (they write two backend config files instead of one) — don't mix the two unless you actually run a dual-backend setup.

### Linux Example Usage

#### Single backend, with tag and zone (Linux)

```bash
./instana-agent-installation.sh -a agent-key -d agent-key -t agent-tag -z agent-zone -p package-path
```

#### Self-hosted / on-prem backend (Linux)

```bash
./instana-agent-installation.sh -a agent-key -d agent-key -t agent-tag -z agent-zone -p package-path -b agent-acceptor.instana.your-domain.com -P 443
```

#### Multi-backend, two Instana endpoints (Linux)

```bash
./instana-agent-installation.sh -a agent-key -d agent-key -t agent-tag -z agent-zone -p package-path -e first-host -g second-host
```

#### With a pre-configured mvn-settings file (Linux)

```bash
./instana-agent-installation.sh -a agent-key -d agent-key -t agent-tag -z agent-zone -p package-path -e first-host -g second-host -u mvn-settings.xml
```

### Linux Uninstall

**RHEL (rpm):**

```bash
rpm -qa | grep instana-agent
rpm -e <package-name>
```

**Debian (dpkg):**

```bash
dpkg -l | grep instana-agent
dpkg -r <package-name>
```

**Cleanup (both):**

```bash
rm -rf /opt/instana
```

## Windows Installation

### Windows Configuration Options

| Parameter | Default | Description |
| --- | --- | --- |
| `INSTANA_AGENT_KEY` | — (required) | Agent key |
| `INSTANA_DOWNLOAD_KEY` | — (required) | Download key |
| `INSTANA_PACKAGE_PATH` | — (required) | Local path to the downloaded installer |
| `INSTANA_AGENT_ENDPOINT` | `ingress-blue-saas.instana.io` | Backend host — set this for a self-hosted/on-prem Instana backend |
| `INSTANA_AGENT_ENDPOINT_PORT` | `443` | Backend port |
| `INSTANA_AGENT_HOST_ONE` | "" | First backend host for **multi-backend** setups (leave empty for single-backend) |
| `INSTANA_AGENT_HOST_TWO` | "" | Second backend host for **multi-backend** setups (leave empty for single-backend) |
| `INSTANA_MVN_CONF_PATH` | "" | Path to a pre-configured `mvn-settings.xml` |
| `AGENT_TAG` | "" | Agent tag |
| `AGENT_ZONE` | "" | Agent zone |

> `INSTANA_AGENT_ENDPOINT`/`_PORT` set the **single-backend** endpoint (SaaS or self-hosted) used at install time. `INSTANA_AGENT_HOST_ONE`/`_TWO` are a separate, independent mechanism for **multi-backend** setups (they write two backend config files after install) — don't mix the two unless you actually run a dual-backend setup.

### Windows Example Usage

#### Single backend, with tag and zone (Windows)

```powershell
.\instana-agent-installation.ps1 -AGENT_ZONE agentzone -AGENT_TAG agenttag -INSTANA_PACKAGE_PATH exepackagepath -INSTANA_AGENT_KEY agent_key -INSTANA_DOWNLOAD_KEY download_key
```

#### Self-hosted / on-prem backend (Windows)

```powershell
.\instana-agent-installation.ps1 -AGENT_ZONE agentzone -AGENT_TAG agenttag -INSTANA_PACKAGE_PATH exepackagepath -INSTANA_AGENT_KEY agent_key -INSTANA_DOWNLOAD_KEY download_key -INSTANA_AGENT_ENDPOINT agent-acceptor.instana.your-domain.com -INSTANA_AGENT_ENDPOINT_PORT 443
```

#### Multi-backend, two Instana endpoints (Windows)

```powershell
.\instana-agent-installation.ps1 -AGENT_ZONE agentzone -AGENT_TAG agenttag -INSTANA_AGENT_HOST_ONE firsthost -INSTANA_AGENT_HOST_TWO secondhost -INSTANA_PACKAGE_PATH exepackagepath -INSTANA_AGENT_KEY agent_key -INSTANA_DOWNLOAD_KEY download_key
```

#### With a pre-configured mvn-settings file (Windows)

```powershell
.\instana-agent-installation.ps1 -AGENT_ZONE agentzone -AGENT_TAG agenttag -INSTANA_AGENT_HOST_ONE firsthost -INSTANA_AGENT_HOST_TWO secondhost -INSTANA_PACKAGE_PATH exepackagepath -INSTANA_AGENT_KEY agent_key -INSTANA_DOWNLOAD_KEY download_key -INSTANA_MVN_CONF_PATH mvnsettingspath
```

### Windows Uninstall

- Remove Instana from **Add or Remove Programs**
- Delete the leftover directory at `C:\Program Files\Instana`
