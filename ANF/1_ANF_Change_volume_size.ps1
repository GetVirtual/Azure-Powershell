<# 
Version: 1.0
Date: 12.11.2020

Description:
This script changes the size of an existing ANF volume on the fly.
The default values point to the Volume created with the "ANF_0_Create_sample_environment.ps1" script.
If you altered values in the base script you have to modify this script variables as well.

Required Modules:
Install-Module -Name Az -AllowClobber -Force
Install-Module -Name Az.NetAppFiles -Force

Authors:
Jürgen Lobenz (Microsoft)
Dirk Ecker (Microsoft/NetApp)
#>

Param (
    [parameter(Mandatory=$true)][String]$SubscriptionId,
    [parameter(Mandatory=$true)][Integer]$NewVolumeSizeGiB
)

# Variables
$Location = "westeurope"
$ResourceGroup = "ANF-PowerShell"

$ANFAccountName = "ANF-Account-PowerShell"
$ANFPoolName = "ANF-Pool-PowerShell"
$ANFVolumeName = "ANF-VolumeNFS-Powershell"
$NewVolumeSizeBytes = $NewVolumeSizeGiB * 1024 * 1024 * 1024

# Connect to Azure
Write-Host "Connecting to Azure subscription $($SubscriptionId)."
Connect-AzAccount -Subscription $SubscriptionId

# Increase volume throughput by increasing the volume size
$Vol = Get-AzNetAppFilesVolume -ResourceGroupName $ResourceGroup -AccountName $ANFAccountName -PoolName $ANFPoolName -Name $ANFVolumeName

Write-Host "Changing size of ANF volume $($ANFVolumeName) from $($Vol.UsageThreshold/1GB) GiB to $($NewVolumeSize) GiB."
Update-AzNetAppFilesVolume -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -AccountName $ANFAccountName `
    -PoolName $ANFPoolName `
    -Name $ANFVolumeName `
    -UsageThreshold $NewVolumeSizeBytes
    
