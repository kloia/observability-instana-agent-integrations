# -----------------------------------------------------------------------------
# Script: update_agent_mode.ps1
# Author: Kloia (https://www.kloia.com/)
# Created by: Observability Team
# Description: This script backs up and updates the 'mode' setting to OFF
#              in the specified configuration file.
# Usage: .\update_agent_mode.ps1
# -----------------------------------------------------------------------------

$configFile = "C:\Program Files\Instana\instana-agent\etc\instana\com.instana.agent.main.config.UpdateManager.cfg"
$serviceName = "instana-agent-service"

Write-Output "---- The configuration process is starting, please wait a few minutes ----"

if (Test-Path -Path $configFile) {
    Copy-Item -Path $configFile -Destination "$configFile.bak"
    Write-Output "Backup of the configuration file created at $configFile.bak"

    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($null -ne $service) {
        if ($service.Status -ne 'Stopped') {
            Stop-Service -Name $serviceName -Force
            Write-Output "Instana Agent Service stopped!"
        } else {
            Write-Output "Instana Agent Service is already stopped."
        }

        $modeExists = Select-String -Path $configFile -Pattern '^mode\s*='

        if ($modeExists) {
            (Get-Content -Path $configFile) -replace '^mode\s*=\s*.*', 'mode = OFF' | Set-Content -Path $configFile
            Write-Output "Update: Dynamic agent mode has been set to OFF in $configFile"
        } else {
            Add-Content -Path $configFile -Value 'mode = OFF'
            Write-Output "Update: Dynamic agent mode has been added with OFF in $configFile"
        }
  
        Start-Service -Name $serviceName
        Write-Output "Instana Agent Service started successfully!"
    } else {
        Write-Output "Error: Service $serviceName not found."
        exit 1
    }
} else {
    Write-Output "Error: Configuration file $configFile not found."
    exit 1
}

