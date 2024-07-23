#!/bin/bash

# -----------------------------------------------------------------------------
# Script: update_agent_mode.sh
# Author: Kloia (https://www.kloia.com/)
# Created by: Observability Team
# Description: This script backs up and updates the 'mode' setting to OFF
#              in the specified configuration file.
# Usage: chmod +x update_agent_mode.sh && sudo ./update_agent_mode.sh
# -----------------------------------------------------------------------------

CONFIG_FILE="/opt/instana/agent/etc/instana/com.instana.agent.main.config.UpdateManager.cfg"

SERVICE_NAME="instana-agent.service"

echo "The configuration process is starting, please wait a few minutes"
echo "--------------------------------------------------------------------------"
if [[ -f "$CONFIG_FILE" ]]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
    echo "Backup of the configuration file created at $CONFIG_FILE.bak"

    # Check if the service is active (running)
    if systemctl is-active --quiet $SERVICE_NAME; then
        systemctl stop $SERVICE_NAME
        echo "Instana Agent Service stopped!"
    else
        echo "Instana Agent Service is already stopped."
    fi
    if grep -q "mode" "$CONFIG_FILE"; then  
       sed -i 's/^mode *= *.*/mode = OFF/' "$CONFIG_FILE"
       echo "Update: Dynamic agent mode has been set to OFF in $CONFIG_FILE"
    else
       echo "mode = OFF" >> "$CONFIG_FILE"
       echo "Update: Dynamic agent mode has been added with OFF in $CONFIG_FILE"
    fi  
    systemctl start $SERVICE_NAME
    echo "Instana Agent Service started successfully!"
else
    echo "Error: Configuration file $CONFIG_FILE not found."
    exit 1
fi

