<# 
Version: 1.0
Date: 12.11.2020

Description:
This script deletes the complete resource group that was created in the first script (ANF_0_Create_sample_environment.ps1)

Required Modules:
Install-Module -Name Az -AllowClobber -Force
Install-Module -Name Az.NetAppFiles -Force

Authors:
Jürgen Lobenz (Microsoft)
Dirk Ecker (Microsoft/NetApp)
#> 

Param (
    [parameter(Mandatory=$true)][String]$SubscriptionId
)

$ResourceGroup = "ANF-PowerShell"

# Connect to Azure
Write-Host "Connecting to Azure subscription $($SubscriptionId)."
Connect-AzAccount -Subscription $SubscriptionId

Remove-AzResourceGroup -Name $ResourceGroup
