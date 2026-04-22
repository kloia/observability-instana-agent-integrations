#!/bin/bash
#-------------------------------------------------------------------------
# Script: update_agent_host.sh
# Author: Kloia (https://www.kloia.com/)
# Created by: Observability Team
# Description: This script backs up and updates the 'host adresses'
#              in the specified configuration file.
# Usage: chmod +x update_agent_mode.sh && sudo ./update_agent_mode.sh
# -----------------------------------------------------------------------------

CONFIG_FILE="/opt/instana/agent/etc/instana/com.instana.agent.main.sender.Backend.cfg"
SERVICE_NAME="instana-agent.service"


echo "Instana agent host configuration process is starting, please wait a few minutes"
echo "--------------------------------------------------------------------------"


if [[ -f "$CONFIG_FILE" ]]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
    echo "Backup of the configuration file created at $CONFIG_FILE.bak"


    cat <<EOF > $CONFIG_FILE
# Configures connection to the Instana SaaS. Changes will be hot-reloaded.


# Host and Port usually do not need to be changed, but can be modified to
# tunnel connections. 
host=agent-acceptor.instana.turkiyesigorta.com.tr
port=8443
protocol=HTTP/2


# By setting a comma separated list of certificate fingerprints, the agent will
# refuse connection in case any other certificate is presented by the server.
# This prevents MITM attacks, but some situations might require to accept
# certificates other than Instana ones or even any certificate.
# fingerprints=29:17:5A:F4:2E:35:DF:87:D6:1F:4D:C8:A8:01:D2:43:18:47:BF:6E


# The HTTP/2 connection to Instana SaaS can be proxied.


## Proxy Server
# proxy.host=
# proxy.port=
## Supported proxy.type values are "http", "socks4", "socks5"
# proxy.type=
## If proxy.dns is set to "true", no local DNS resolution is attempted
# proxy.dns=true
## Some proxy servers require authentication
# proxy.user=
# proxy.password=


# Access Key for your SaaS installation. Is pre-filled during agent download.
key=7dfy3RQgFOcKVF58WQLl0K
EOF
    echo "Update: Agent host and port adress has been changed in $CONFIG_FILE"


    if systemctl is-active --quiet $SERVICE_NAME; then
        systemctl stop $SERVICE_NAME
        echo "Instana Agent Service stopped!"
    else
        echo "Instana Agent Service is already stopped."
    fi


    systemctl start $SERVICE_NAME


    if systemctl is-active --quiet $SERVICE_NAME; then
        echo "Instana Agent Service started successfully!"
    else
        echo "Failed to start Instana Agent Service."
        exit 1
    fi
else
    echo "Error: Configuration file $CONFIG_FILE not found."
    exit 1
fi
